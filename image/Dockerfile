# Use osixia/light-baseimage
# sources: https://github.com/osixia/docker-light-baseimage
FROM osixia/light-baseimage:1.1.1
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# MariaDB version
ARG MARIADB_MAJOR=10.2
ARG MARIADB_VERSION=10.2.11+maria~stretch

# Add mysql user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
# https://github.com/docker-library/mariadb/blob/master/10.0/Dockerfile
RUN groupadd -r mysql && useradd -r -g mysql mysql

# Add MariaDB and Percona repositories
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8 \
    && echo "deb http://ftp.igh.cnrs.fr/pub/mariadb/repo/$MARIADB_MAJOR/debian stretch main" > /etc/apt/sources.list.d/mariadb.list \
    && apt-key adv --keyserver keys.gnupg.net --recv-keys 0x9334A25F8507EFA5 \
    && echo "deb https://repo.percona.com/apt stretch main" > /etc/apt/sources.list.d/percona.list \
    && { \
		     echo 'Package: *'; \
		     echo 'Pin: release o=MariaDB'; \
		     echo 'Pin-Priority: 999'; \
	     } > /etc/apt/preferences.d/mariadb
     # add repository pinning to make sure dependencies from this MariaDB repo are preferred over Debian dependencie

# Add multiple process stack and ssl tools
# sources: https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/add-multiple-process-stack
#          https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/add-service-available
#          https://github.com/osixia/docker-light-baseimage/blob/stable/image/service-available/:ssl-tools/download.sh
# Install MariaDB and xtrabackup
RUN apt-get -y update \
    && /container/tool/add-multiple-process-stack \
    && /container/tool/add-service-available :ssl-tools \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
       mariadb-server=$MARIADB_VERSION \
       percona-xtrabackup-24 \
       qpress \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add service directory to /container/service
ADD service /container/service

# Use baseimage install-service script
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/install-service
RUN /container/tool/install-service

# Add default env variables
ADD environment /container/environment/99-default

# Set MariaDB database and backup directories in data volumes
VOLUME ["/var/lib/mysql", "/data/backup"]

# Expose MariaDB default port
EXPOSE 3306
