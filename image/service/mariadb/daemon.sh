#!/bin/bash -e

if [ "${MARIADB_SSL,,}" == "true" ]; then
  echo "start mariadb with ssl support"
  exec /usr/bin/mysqld_safe --ssl --ssl-cipher=$MARIADB_SSL_CIPHER_SUITE --ssl-ca=/container/service/mariadb/assets/certs/$MARIADB_SSL_CA_CRT_FILENAME --ssl-cert=/container/service/mariadb/assets/certs/$MARIADB_SSL_CRT_FILENAME --ssl-key=/container/service/mariadb/assets/certs/$MARIADB_SSL_KEY_FILENAME
else
  echo "start mariadb"
  exec /usr/bin/mysqld_safe
fi
