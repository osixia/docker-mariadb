#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x


FIRST_START_DONE="${CONTAINER_STATE_DIR}/docker-mariadb-xtrabackup-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # add image tools
  ln -s ${CONTAINER_SERVICE_DIR}/xtrabackup/assets/tool/* /sbin/

  # add cron jobs
  ln -s ${CONTAINER_SERVICE_DIR}/xtrabackup/assets/cronjobs /etc/cron.d/xtrabackup
  chmod 600 ${CONTAINER_SERVICE_DIR}/xtrabackup/assets/cronjobs


  # adapt cronjobs file
  sed -i --follow-symlinks "s|{{ MARIADB_BACKUP_CRON_EXP }}|${MARIADB_BACKUP_CRON_EXP}|g" ${CONTAINER_SERVICE_DIR}/xtrabackup/assets/cronjobs

  touch $FIRST_START_DONE
fi

exit 0
