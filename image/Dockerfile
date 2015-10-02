FROM osixia/light-baseimage:0.1.1
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# MariaDB version
ENV MARIADB_MAJOR 10.1
ENV MARIADB_VERSION 10.1.7+maria-1~jessie

# Use baseimage's init system.
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/run
CMD ["/container/tool/run"]

# Add mysql user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
# https://github.com/docker-library/mariadb/blob/master/10.0/Dockerfile
RUN groupadd -r mysql && useradd -r -g mysql mysql

# Add MariaDB and Percona repositories
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db \
    && echo "deb http://ftp.igh.cnrs.fr/pub/mariadb/repo/$MARIADB_MAJOR/debian jessie main" > /etc/apt/sources.list.d/mariadb.list \
    && apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A \
    && echo "deb http://repo.percona.com/apt jessie main" > /etc/apt/sources.list.d/percona.list \
    && { \
		     echo 'Package: *'; \
		     echo 'Pin: release o=MariaDB'; \
		     echo 'Pin-Priority: 999'; \
	     } > /etc/apt/preferences.d/mariadb
     # add repository pinning to make sure dependencies from this MariaDB repo are preferred over Debian dependencie

# Install MariaDB, xtrabackup and remove default db
RUN apt-get -y update \
    && /container/tool/install-multiple-process-stack \
    && /container/tool/install-service-available ssl-helper-openssl \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
       mariadb-server=$MARIADB_VERSION percona-xtrabackup \
    && rm -rf /var/lib/mysql \
    && mkdir /var/lib/mysql

# Add service directory to /container/service
ADD service /container/service

# Use baseimage install-service script and clean all
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/install-service
RUN /container/tool/install-service \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add default env variables
ADD env.yaml /etc/env.yaml

# Set MariaDB database directory in a data volume
VOLUME ["/var/lib/mysql"]

# Expose MariaDB default port
EXPOSE 3306
