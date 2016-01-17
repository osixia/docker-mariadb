#!/bin/bash -e

FIRST_START_DONE="/etc/docker-mariadb-xtrabackup-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # add image tools
  ln -s ${CONTAINER_STATE_DIR}/xtrabackup/assets/tool/* /sbin/

  # add cron jobs
  ln -s ${CONTAINER_STATE_DIR}/xtrabackup/assets/cronjobs /etc/cron.d/xtrabackup
  chmod 600 ${CONTAINER_STATE_DIR}/xtrabackup/assets/cronjobs


  # adapt cronjobs file
  sed -i --follow-symlinks "s|{{ MARIADB_BACKUP_CRON_EXP }}|${MARIADB_BACKUP_CRON_EXP}|g" ${CONTAINER_STATE_DIR}/xtrabackup/assets/cronjobs

  touch $FIRST_START_DONE
fi

exit 0
