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

# The password for 'debian-sys-maint'@'localhost' is auto generated.
# The database inside of DATA_DIR may not have been generated with this password.
# So, we need to set this for our database to be portable.
# https://github.com/Painted-Fox/docker-mariadb/blob/master/scripts/first_run.sh
DB_MAINT_PASS=$(cat /etc/mysql/debian.cnf | grep -m 1 "password\s*=\s*"| sed 's/^password\s*=\s*//')

FIRST_START_DONE="${CONTAINER_STATE_DIR}/docker-mariadb-first-start-done"
# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  #
  # SSL config
  #
  if [ "${MARIADB_SSL,,}" == "true" ]; then
    log-helper info "SSL config..."

    # generate a certificate and key with cfssl tool if LDAP_CRT and LDAP_KEY files don't exists
    # https://github.com/osixia/docker-light-baseimage/blob/stable/image/service-available/:cfssl/assets/tool/cfssl-helper
    cfssl-helper ${MARIADB_CFSSL_PREFIX} "${CONTAINER_SERVICE_DIR}/mariadb/assets/certs/$MARIADB_SSL_CRT_FILENAME" "${CONTAINER_SERVICE_DIR}/mariadb/assets/certs/$MARIADB_SSL_KEY_FILENAME" "${CONTAINER_SERVICE_DIR}/mariadb/assets/certs/$MARIADB_SSL_CA_CRT_FILENAME"
    chown -R mysql:mysql ${CONTAINER_SERVICE_DIR}/mariadb
  fi

  #
  # We have a custom config file
  #
  if [ -e ${CONTAINER_SERVICE_DIR}/mariadb/assets/my.cnf ]; then

    log-helper info "Use config file: ${CONTAINER_SERVICE_DIR}/mariadb/assets/my.cnf ..."
    rm /etc/mysql/my.cnf
    cp ${CONTAINER_SERVICE_DIR}/mariadb/assets/my.cnf /etc/mysql/my.cnf

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
  if [ -z "$(ls -A /var/lib/mysql)" ]; then

    log-helper info "Init new database..."

    # initializes the MySQL data directory and creates the system tables that it contains
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --rpm

    # start MariaDB
    log-helper info "Start MariaDB..."
    service mysql start || true

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

    # add debian user for maintenance operations
    echo "GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '$DB_MAINT_PASS' ;" >> "$TEMP_FILE"

    # add backup user
    echo "CREATE USER '$MARIADB_BACKUP_USER'@'localhost' IDENTIFIED BY '$MARIADB_BACKUP_PASSWORD';" >> "$TEMP_FILE"
    echo "GRANT RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO '$MARIADB_BACKUP_USER'@'localhost';" >> "$TEMP_FILE"

    # flush privileges
    echo "FLUSH PRIVILEGES ;" >> "$TEMP_FILE"

    # execute config queries
    mysql -u root < $TEMP_FILE
  fi

  cp -f /etc/mysql/my.cnf ${CONTAINER_SERVICE_DIR}/mariadb/assets/my.cnf

  touch $FIRST_START_DONE
fi

# if mariadb is not already started
if [ ! -e "/var/run/mysqld/mysqld.pid" ]; then
  log-helper info "Start mariadb..."
  service mysql start || true

  # add debian user for maintenance operations
cat > "$TEMP_FILE" <<-EOSQL
    DELETE FROM mysql.user where user = 'debian-sys-maint' ;
    FLUSH PRIVILEGES ;
    GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '$DB_MAINT_PASS' ;
    FLUSH PRIVILEGES ;
EOSQL
  mysql -u $MARIADB_ROOT_USER -p$MARIADB_ROOT_PASSWORD < $TEMP_FILE
fi

rm $TEMP_FILE

log-helper info "Stop MariaDB..."
MARIADB_PID=$(cat /var/run/mysqld/mysqld.pid)
kill -15 $MARIADB_PID
while [ -e /proc/$MARIADB_PID ]; do sleep 0.1; done # wait until slapd is terminated

ln -sf ${CONTAINER_SERVICE_DIR}/mariadb/assets/my.cnf /etc/mysql/my.cnf
ln -sf ${CONTAINER_SERVICE_DIR}/mariadb/assets/conf.d/* /etc/mysql/conf.d/

exit 0
