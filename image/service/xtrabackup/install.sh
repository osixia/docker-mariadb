#!/bin/bash -e
# this script is run during the image build

# install image tools
ln -s /container/service/xtrabackup/assets/tool/* /sbin/

# add cron jobs
ln -s /container/service/xtrabackup/assets/cronjobs /etc/cron.d/xtrabackup
chmod 600 /container/service/xtrabackup/assets/cronjobs
