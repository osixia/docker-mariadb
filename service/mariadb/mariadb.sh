#!/bin/sh

set -eu

status () {
  echo "---> ${@}" >&2
}

set -x
: ROOT_USER=${ROOT_USER}
: ROOT_PWD=${ROOT_PWD}

# Start MariaDB
service mysql start

############ Base config ############
if [ ! -e /var/lib/mysql/docker_bootstrapped ]; then
  status "configuring MariaDB database"

  # Run mysql_secure_installation
  expect config/config.exp

  # Disable this ability to load local files 
  sed -i '/\[mysqld\]/a\local-infile=0' /etc/mysql/my.cnf

  # Allow Remote Client Access
  sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

  # Change root username
  mysql -u root -p$ROOT_PWD -e "UPDATE mysql.user SET user='${ROOT_USER}' WHERE user='root';"
  mysql -u root -p$ROOT_PWD -e 'FLUSH PRIVILEGES;'

  touch /var/lib/mysql/docker_bootstrapped

else
  status "MariaDB database found"
fi

# The password for 'debian-sys-maint'@'localhost' is auto generated.
# The database inside of DATA_DIR may not have been generated with this password.
# So, we need to set this for our database to be portable.
# https://github.com/Painted-Fox/docker-mariadb/blob/master/scripts/first_run.sh

DB_MAINT_PASS=$(cat /etc/mysql/debian.cnf | grep -m 1 "password\s*=\s*"| sed 's/^password\s*=\s*//')

mysql -u $ROOT_USER -p$ROOT_PWD -e "UPDATE mysql.user SET Password=PASSWORD('$DB_MAINT_PASS') WHERE User='debian-sys-maint';"
mysql -u $ROOT_USER -p$ROOT_PWD -e 'FLUSH PRIVILEGES;'

service mysql stop

exec /usr/bin/mysqld_safe
