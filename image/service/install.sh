#!/bin/bash -e
# this script is run during the image build

# MariaDB config

# We have a custom config file 
if [ -e /osixia/mariadb/my.cnf ]; then

  rm /etc/mysql/my.cnf
  ln -s /osixia/mariadb/my.cnf /etc/mysql/my.cnf

else
  # Modify the default config file

  # Allow remote connection
  sed -ri 's/^(bind-address|skip-networking)/;\1/' /etc/mysql/my.cnf

  # Disable local files loading
  sed -i '/\[mysqld\]/a\local-infile=0' /etc/mysql/my.cnf

fi