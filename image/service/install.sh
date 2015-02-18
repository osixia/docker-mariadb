#!/bin/bash -e
# this script is run during the image build

# set python encoded envvar to decode
touch /etc/decode-envvar/ROOT_ALLOWED_NETWORKS

# MariaDB config

# Allow remote connection
sed -ri 's/^(bind-address|skip-networking)/;\1/' /etc/mysql/my.cnf

# Disable local files loading
sed -i '/\[mysqld\]/a\local-infile=0' /etc/mysql/my.cnf