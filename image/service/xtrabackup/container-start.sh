#!/bin/bash -e

FIRST_START_DONE="/etc/docker-mariadb-xtrabackup-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # adapt cronjobs file
  sed -i --follow-symlinks "s|{{ MARIADB_BACKUP_CRON_EXP }}|${MARIADB_BACKUP_CRON_EXP}|g" /container/service/xtrabackup/assets/cronjobs

  touch $FIRST_START_DONE
fi

exit 0
