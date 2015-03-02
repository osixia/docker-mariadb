FROM osixia/baseimage:0.10.3
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# MariaDB version
ENV MARIADB_MAJOR 10.0
ENV MARIADB_VERSION 10.0.17+maria-1~trusty

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Add mysql user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
# https://github.com/docker-library/mariadb/blob/master/10.0/Dockerfile
RUN groupadd -r mysql && useradd -r -g mysql mysql

# Add MariaDB repository
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db \
    && echo "deb http://ftp.igh.cnrs.fr/pub/mariadb/repo/$MARIADB_MAJOR/ubuntu trusty main" > /etc/apt/sources.list.d/mariadb.list

# Install MariaDB , remove default db,
RUN apt-get -y update \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    mariadb-server=$MARIADB_VERSION \
    && rm -rf /var/lib/mysql \
    && mkdir /var/lib/mysql 

# Add install script and MariaDB assets
ADD service/install.sh /tmp/install.sh
ADD service/mariadb/assets /osixia/mariadb

# Run install script and clean all
RUN ./tmp/install.sh \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add default env variables
ADD env.yml /etc/env.yml

# Add MariaDB container start config & daemon
ADD service/mariadb/container-start.sh /etc/my_init.d/mariadb
ADD service/mariadb/daemon.sh /etc/service/mariadb/run

# Set MariaDB database directory in a data volume
VOLUME ["/var/lib/mysql"]

# Expose MariaDB default port
EXPOSE 3306