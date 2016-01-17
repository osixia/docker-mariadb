#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

if [ "${MARIADB_SSL,,}" == "true" ]; then
  log-helper info "Start mariadb with ssl..."
  exec /usr/bin/mysqld_safe --ssl --ssl-cipher=$MARIADB_SSL_CIPHER_SUITE --ssl-ca=/container/service/mariadb/assets/certs/$MARIADB_SSL_CA_CRT_FILENAME --ssl-cert=/container/service/mariadb/assets/certs/$MARIADB_SSL_CRT_FILENAME --ssl-key=/container/service/mariadb/assets/certs/$MARIADB_SSL_KEY_FILENAME
else
  log-helper info "Start mariadb..."
  exec /usr/bin/mysqld_safe
fi
