#!/bin/bash

# fix permissions and ownership of /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql
chmod 700 /var/lib/mysql

# config sql queries
TEMP_FILE='/tmp/mysql-start.sql'

# The password for 'debian-sys-maint'@'localhost' is auto generated.
# The database inside of DATA_DIR may not have been generated with this password.
# So, we need to set this for our database to be portable.
# https://github.com/Painted-Fox/docker-mariadb/blob/master/scripts/first_run.sh
DB_MAINT_PASS=$(cat /etc/mysql/debian.cnf | grep -m 1 "password\s*=\s*"| sed 's/^password\s*=\s*//')

# database is uninitialized
if [ -z "$(ls -A /var/lib/mysql)" ]; then

  # Initializes the MySQL data directory and creates the system tables that it contains
  mysql_install_db --datadir=/var/lib/mysql

  # allow remote connection
  sed -ri 's/^(bind-address|skip-networking)/;\1/' /etc/mysql/my.cnf

  # Disable local files loading
  sed -i '/\[mysqld\]/a\local-infile=0' /etc/mysql/my.cnf

  # Start MariaDB
  service mysql start || true

  # drop all user and test database
  cat > "$TEMP_FILE" <<-EOSQL
      DELETE FROM mysql.user ;
      DROP DATABASE IF EXISTS test ;
EOSQL

  # add root user on specified networks
  IFS=', ' read -a networks <<< "$ROOT_ALLOWED_NETWORKS"
  for network in "${networks[@]}"
  do
    echo "CREATE USER '$ROOT_USER'@'$network' IDENTIFIED BY '$ROOT_PWD' ;" >> "$TEMP_FILE"
    echo "GRANT ALL ON *.* TO '$ROOT_USER'@'$network' WITH GRANT OPTION ;" >> "$TEMP_FILE"
  done

  echo "CREATE USER 'debian-sys-maint'@'localhost' IDENTIFIED BY '$DB_MAINT_PASS' ;" >> "$TEMP_FILE"
  echo "GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '$DB_MAINT_PASS' ;" >> "$TEMP_FILE"
  
  # Flush privileges
  echo 'FLUSH PRIVILEGES ;' >> "$TEMP_FILE"

  # execute config queries
  mysql -u root < $TEMP_FILE

  # prevent socket error on stop
  sleep 1

  # Stop MariaDB
  service mysql stop

# database is initialized
else

  # Start MariaDB
  service mysql start || true

  # drop all user and test database
  cat > "$TEMP_FILE" <<-EOSQL
      DELETE FROM mysql.user where user = 'debian-sys-maint' ;
      FLUSH PRIVILEGES ;
      CREATE USER 'debian-sys-maint'@'localhost' IDENTIFIED BY '$DB_MAINT_PASS' ;
      GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '$DB_MAINT_PASS' ;
      FLUSH PRIVILEGES ;
EOSQL

  # execute config queries
  mysql -u $ROOT_USER -p$ROOT_PWD < $TEMP_FILE

  # prevent socket error on stop
  sleep 1

  # Stop MariaDB
  service mysql stop

fi

rm $TEMP_FILE

exit 0