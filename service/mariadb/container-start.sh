#!/bin/bash

# fix permissions and ownership of /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql
chmod 700 /var/lib/mysql

# database is uninitialized
if [ -z "$(ls -A /var/lib/mysql)" ]; then

  if [ -z "$ROOT_USER" ]; then
    echo >&2 '/!\ Error: database is uninitialized and ROOT_USER not set'
    echo >&2 'Did you forget to add -e ROOT_USER=... ?'
    exit 1
  fi

  if [ -z "$ROOT_PWD" ]; then
    echo >&2 '/!\ Error: database is uninitialized and ROOT_PWD not set'
    echo >&2 'Did you forget to add -e ROOT_PWD=... ?'
    exit 1
  fi

  # set root user default allowed networks if needed
  if [ -z "$ROOT_ALLOWED_NETWORKS" ]; then
    ROOT_ALLOWED_NETWORKS='localhost,127.0.0.1,::1'
  fi

  # Initializes the MySQL data directory and creates the system tables that it contains
  mysql_install_db --datadir=/var/lib/mysql

  # allow remote connection
  sed -ri 's/^(bind-address|skip-networking)/;\1/' /etc/mysql/my.cnf

  # Disable local files loading
  sed -i '/\[mysqld\]/a\local-infile=0' /etc/mysql/my.cnf

  # Start MariaDB
  service mysql start || true
  
  # hold config sql queries
  TEMP_FILE='/tmp/mysql-first-time.sql'

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

  # The password for 'debian-sys-maint'@'localhost' is auto generated.
  # The database inside of DATA_DIR may not have been generated with this password.
  # So, we need to set this for our database to be portable.
  # https://github.com/Painted-Fox/docker-mariadb/blob/master/scripts/first_run.sh
  DB_MAINT_PASS=$(cat /etc/mysql/debian.cnf | grep -m 1 "password\s*=\s*"| sed 's/^password\s*=\s*//')
  echo "CREATE USER 'debian-sys-maint'@'localhost' IDENTIFIED BY '$DB_MAINT_PASS' ;" >> "$TEMP_FILE"
  echo "GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '$DB_MAINT_PASS';" >> "$TEMP_FILE"
  
  # Flush privileges
  echo 'FLUSH PRIVILEGES ;' >> "$TEMP_FILE"

  # execute config queries
  mysql -u root < $TEMP_FILE

  rm $TEMP_FILE

  # Stop MariaDB
  service mysql stop
fi
