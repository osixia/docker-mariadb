#!/bin/sh

set -eu

status () {
  echo "---> ${@}" >&2
}

ROOT_USER=${ROOT_USER}
ROOT_PWD=${ROOT_PWD}

############ Base config ############
if [ ! -e /var/lib/mysql/docker_bootstrapped ]; then
  status "configuring MariaDB database"
  
  # Start MariaDB
  service mysql start

  # Run mysql_secure_installation
  expect config/config.exp

  # Disable this ability to load local files 
  sed -i '/\[mysqld\]/a\local-infile=0' /etc/mysql/my.cnf

  # Change root username
  mysql -u root -p$ROOT_PWD -e "UPDATE mysql.user SET user='${ROOT_USER}' WHERE user='root';"
  mysql -u root -p$ROOT_PWD -e 'FLUSH PRIVILEGES;'

  service mysql stop

  touch /var/lib/mysql/docker_bootstrapped

else
  status "MariaDB database found"
fi

exec /usr/bin/mysqld_safe
