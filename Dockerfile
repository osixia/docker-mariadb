FROM osixia/baseimage:0.10.1
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# /!\ Mount /var/lib/mysql as data volume 
# to save mysql data outside the container

# Default configuration: can be overridden at the docker command line
ENV ROOT_USER admin
ENV ROOT_PWD toor
ENV ROOT_ALLOWED_NETWORKS localhost,127.0.0.1,::1

# MariaDb version
ENV MARIADB_MAJOR 10.0
ENV MARIADB_VERSION 10.0.15+maria-1~trusty

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Add mysql user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
# https://github.com/docker-library/mariadb/blob/master/10.0/Dockerfile
RUN groupadd -r mysql && useradd -r -g mysql mysql

# Add MariaDB repository
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
RUN echo "deb http://ftp.igh.cnrs.fr/pub/mariadb/repo/$MARIADB_MAJOR/ubuntu trusty main" > /etc/apt/sources.list.d/mariadb.list

# Install MariaDB needed for automatic config
RUN apt-get -y update \ 
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    mariadb-server=$MARIADB_VERSION \
    && rm -rf /var/lib/mysql \
    && mkdir /var/lib/mysql

# Expose MariaDB default port
EXPOSE 3306

# Allow saving data outside the container
VOLUME ["/var/lib/mysql"]

# Add MariaDB container start config & daemon
ADD service/mariadb/container-start.sh /etc/my_init.d/mariadb
ADD service/mariadb/daemon.sh /etc/service/mariadb/run


# Clear out the local repository of retrieved package files
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
