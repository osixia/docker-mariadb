#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

# fix permissions and ownership of /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql
chmod 700 /var/lib/mysql
chown -R mysql:mysql ${CONTAINER_SERVICE_DIR}/mariadb

# config sql queries
TEMP_FILE='/tmp/mysql-start.sql'

ln -sf ${CONTAINER_SERVICE_DIR}/mariadb/assets/config/conf.d/* /etc/mysql/conf.d/

FIRST_START_DONE="${CONTAINER_STATE_DIR}/docker-mariadb-first-start-done"
# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  #
  # SSL config
  #
  if [ "${MARIADB_SSL,,}" == "true" ]; then
    log-helper info "SSL config..."

    # generate a certificate and key with ssl-helper if LDAP_CRT and LDAP_KEY files don't exists
    # https://github.com/osixia/docker-light-baseimage/blob/stable/image/service-available/:ssl-tools/assets/tool/ssl-helper
    ssl-helper ${MARIADB_SSL_HELPER_PREFIX} "${CONTAINER_SERVICE_DIR}/mariadb/assets/certs/$MARIADB_SSL_CRT_FILENAME" "${CONTAINER_SERVICE_DIR}/mariadb/assets/certs/$MARIADB_SSL_KEY_FILENAME" "${CONTAINER_SERVICE_DIR}/mariadb/assets/certs/$MARIADB_SSL_CA_CRT_FILENAME"
    chown -R mysql:mysql ${CONTAINER_SERVICE_DIR}/mariadb
  fi

  #
  # We have a custom config file
  #
  if [ -e ${CONTAINER_SERVICE_DIR}/mariadb/assets/config/my.cnf ]; then

    log-helper info "Use config file: ${CONTAINER_SERVICE_DIR}/mariadb/assets/config/my.cnf ..."
    rm /etc/mysql/my.cnf
    ln -sf ${CONTAINER_SERVICE_DIR}/mariadb/assets/config/my.cnf /etc/mysql/my.cnf

  #
  # Use mariadb default config file
  #
  else
    log-helper info "Use default config file: /etc/mysql/my.cnf ..."

    # Allow remote connection
    sed -Ei --follow-symlinks 's/^(bind-address|log)/#&/' /etc/mysql/my.cnf
    # Disable local files loading, don't reverse lookup hostnames, they are usually another container
    sed -i --follow-symlinks '/\[mysqld\]/a\local-infile=0\nskip-host-cache\nskip-name-resolve' /etc/mysql/my.cnf
  fi

  #
  # there is no database
  #
  if [ -z "$(ls -A -I lost+found /var/lib/mysql)" ]; then

    log-helper info "Init new database..."

    # initializes the MySQL data directory and creates the system tables that it contains
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --rpm

    # start MariaDB
    log-helper info "Start MariaDB..."
    /usr/bin/mysqld_safe --skip-networking --socket=/var/run/mysqld/mysqld.sock &

    mysql=( mysql --protocol=socket -uroot -hlocalhost --socket="/var/run/mysqld/mysqld.sock" )

    for i in {30..0}; do
			if echo 'SELECT 1' | "${mysql}" &> /dev/null; then
				break
			fi
			log-helper info "MySQL init process in progress..."
			sleep 1
		done

    if [ "$i" = 0 ]; then
			log-helper error "MySQL init process failed."
			exit 1
		fi

    # drop all user and test database
    cat > "$TEMP_FILE" <<-EOSQL
        DELETE FROM mysql.user ;
        DROP DATABASE IF EXISTS test ;
EOSQL

    # add root user on specified networks
    for network in $(complex-bash-env iterate MARIADB_ROOT_ALLOWED_NETWORKS)
    do
      echo "GRANT ALL PRIVILEGES ON *.* TO '$MARIADB_ROOT_USER'@'${!network}' IDENTIFIED BY '$MARIADB_ROOT_PASSWORD' WITH GRANT OPTION ;" >> "$TEMP_FILE"
    done


    function addUsers() {
      local users=$1
      local databases=$2

      for user in $(complex-bash-env iterate "${users}")
      do
        if [ -n "${!user}" ]; then
          if [ $(complex-bash-env isRow "${!user}") = true ]; then
            u=$(complex-bash-env getRowKey "${!user}")
            p=$(complex-bash-env getRowValue "${!user}")

            echo "CREATE USER '$u'@'%' IDENTIFIED BY '$p' ;" >> "$TEMP_FILE"

            for database in $(complex-bash-env iterate "${databases}")
            do
              if [ $(complex-bash-env isRow "${!database}") = true ]; then
                database=$(complex-bash-env getRowKeyVarName "${!database}")
              fi
              [ -n "${!database}" ] && echo "GRANT ALL ON \`${!database}\`.* TO '$u'@'%' ;"  >> "$TEMP_FILE"
            done

          else
            echo "Error please set a password for user: ${!user}"
            exit 1
          fi
        fi
      done
    }

    # add databases
    for database in $(complex-bash-env iterate MARIADB_DATABASES)
    do
      users=""
      # this datase has users
      if [ $(complex-bash-env isRow "${!database}") = true ]; then
        users=$(complex-bash-env getRowValueVarName "${!database}")
        database=$(complex-bash-env getRowKeyVarName "${!database}")
      fi

      [ -n "${!database}" ] && echo "CREATE DATABASE IF NOT EXISTS \`${!database}\` ;" >> "$TEMP_FILE"

      if [ -n "${users}" ]; then
        # add database specific users
        addUsers "${users}" "${database}"
      fi
    done

    # add global users
    addUsers MARIADB_USERS MARIADB_DATABASES

    # add backup user
    echo "CREATE USER '$MARIADB_BACKUP_USER'@'localhost' IDENTIFIED BY '$MARIADB_BACKUP_PASSWORD';" >> "$TEMP_FILE"
    echo "GRANT PROCESS, RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO '$MARIADB_BACKUP_USER'@'localhost';" >> "$TEMP_FILE"

    # flush privileges
    echo "FLUSH PRIVILEGES ;" >> "$TEMP_FILE"

    log-helper info "Add MariaDB config..."
    cat $TEMP_FILE | log-helper debug

    # execute config queries
    ${mysql} < $TEMP_FILE

    rm $TEMP_FILE

    log-helper info "Stop MariaDB..."
    MARIADB_PID=$(cat /var/run/mysqld/mysqld.pid)
    kill -15 $MARIADB_PID
    while [ -e /proc/$MARIADB_PID ]; do sleep 0.1; done # wait until mariadb is terminated

  fi

  touch $FIRST_START_DONE
fi

exit 0
