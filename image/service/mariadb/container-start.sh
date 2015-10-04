#!/bin/bash -e

FIRST_START_DONE="/etc/docker-mariadb-first-start-done"

# fix permissions and ownership of /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql
chmod 700 /var/lib/mysql
chown -R mysql:mysql /container/service/mariadb

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # ssl
  if [ "${MARIADB_SSL,,}" == "true" ]; then

    # check certificat and key or create it
    /sbin/ssl-helper "/container/service/mariadb/assets/certs/$MARIADB_SSL_CRT_FILENAME" "/container/service/mariadb/assets/certs/$MARIADB_SSL_KEY_FILENAME" --ca-crt=/container/service/mariadb/assets/certs/$MARIADB_SSL_CA_CRT_FILENAME
    chown -R mysql:mysql /container/service/mariadb

  fi


  # We have a custom config file
  if [ -e /container/service/mariadb/assets/my.cnf ]; then

    echo "use config file: /container/service/mariadb/assets/my.cnf"
    rm /etc/mysql/my.cnf
    ln -s /container/service/mariadb/assets/my.cnf /etc/mysql/my.cnf

  else
    # Modify the default config file
    echo "use mariadb default config"

    # Allow remote connection
    sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/my.cnf

    # Disable local files loading, don't reverse lookup hostnames, they are usually another container
    sed -i '/\[mysqld\]/a\local-infile=0\nskip-host-cache\nskip-name-resolve' /etc/mysql/my.cnf
  fi

  # config sql queries
  TEMP_FILE='/tmp/mysql-start.sql'

  # The password for 'debian-sys-maint'@'localhost' is auto generated.
  # The database inside of DATA_DIR may not have been generated with this password.
  # So, we need to set this for our database to be portable.
  # https://github.com/Painted-Fox/docker-mariadb/blob/master/scripts/first_run.sh
  DB_MAINT_PASS=$(cat /etc/mysql/debian.cnf | grep -m 1 "password\s*=\s*"| sed 's/^password\s*=\s*//')

  # database is uninitialized
  if [ -z "$(ls -A /var/lib/mysql)" ]; then

    # initializes the MySQL data directory and creates the system tables that it contains
    mysql_install_db --datadir=/var/lib/mysql

    # start MariaDB
    service mysql start || true

    # drop all user and test database
    cat > "$TEMP_FILE" <<-EOSQL
        DELETE FROM mysql.user ;
        DROP DATABASE IF EXISTS test ;
EOSQL

    # add root user on specified networks
    MARIADB_ROOT_ALLOWED_NETWORKS=($MARIADB_ROOT_ALLOWED_NETWORKS)
    for network in "${MARIADB_ROOT_ALLOWED_NETWORKS[@]}"
    do
      if [ -n "${!network}" ]; then
        echo "GRANT ALL PRIVILEGES ON *.* TO '$MARIADB_ROOT_USER'@'${!network}' IDENTIFIED BY '$MARIADB_ROOT_PASSWORD' WITH GRANT OPTION ;" >> "$TEMP_FILE"
      else
        echo "GRANT ALL PRIVILEGES ON *.* TO '$MARIADB_ROOT_USER'@'${network}' IDENTIFIED BY '$MARIADB_ROOT_PASSWORD' WITH GRANT OPTION ;" >> "$TEMP_FILE"
      fi
    done

    echo "GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '$DB_MAINT_PASS' ;" >> "$TEMP_FILE"

    # add backup user
    echo "CREATE USER '$MARIADB_BACKUP_USER'@'localhost' IDENTIFIED BY '$MARIADB_BACKUP_PASSWORD';" >> "$TEMP_FILE"
    echo "GRANT RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO '$MARIADB_BACKUP_USER'@'localhost';" >> "$TEMP_FILE"

    # flush privileges
    echo "FLUSH PRIVILEGES ;" >> "$TEMP_FILE"

    # execute config queries
    mysql -u root < $TEMP_FILE

    # prevent socket error on stop
    sleep 1

    # Stop MariaDB
    service mysql stop

  # database is initialized
  else

    # start MariaDB
    service mysql start || true

    # drop all user and test database
    cat > "$TEMP_FILE" <<-EOSQL
        DELETE FROM mysql.user where user = 'debian-sys-maint' ;
        FLUSH PRIVILEGES ;
        GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '$DB_MAINT_PASS' ;
        FLUSH PRIVILEGES ;
EOSQL

    # execute config queries
    mysql -u $MARIADB_ROOT_USER -p$MARIADB_ROOT_PASSWORD < $TEMP_FILE

    # prevent socket error on stop
    sleep 1

    # stop MariaDB
    service mysql stop

  fi

  rm $TEMP_FILE

  touch $FIRST_START_DONE
fi

exit 0
