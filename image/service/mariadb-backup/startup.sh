#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

# add image tools
ln -sf "${CONTAINER_SERVICE_DIR}"/mariadb-backup/assets/tool/* /sbin/

# add cron jobs
ln -sf "${CONTAINER_SERVICE_DIR}/mariadb-backup/assets/cronjobs" /etc/cron.d/mariadb-backup
chmod 600 "${CONTAINER_SERVICE_DIR}/mariadb-backup/assets/cronjobs"


FIRST_START_DONE="${CONTAINER_STATE_DIR}/docker-mariadb-mariadb-backup-first-start-done"
# container first start
if [ ! -e "${FIRST_START_DONE}" ]; then

  # adapt cronjobs file
  sed -i "s|{{ MARIADB_BACKUP_CRON_EXP }}|${MARIADB_BACKUP_CRON_EXP}|g" "${CONTAINER_SERVICE_DIR}/mariadb-backup/assets/cronjobs"

  touch "${FIRST_START_DONE}"
fi

exit 0
