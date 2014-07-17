FROM osixia/baseimage:0.6.0
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.fr>

# /!\ Mount /var/lib/mysql as data volume 
# to save mysql data outside the container

# Default configuration: can be overridden at the docker command line
ENV ROOT_USER admin
ENV ROOT_PWD toor

# Set correct environment variables.
ENV HOME /root

# Disable SSH
# RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Add MariaDB repository
RUN apt-get install software-properties-common
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
RUN add-apt-repository 'deb http://ftp.igh.cnrs.fr/pub/mariadb/repo/10.0/ubuntu trusty main'

# Resynchronize the package index files from their sources
RUN apt-get -y update

# Install MariaDB Galera Cluster & expect needed for automatic config
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends mariadb-server expect

# Expose MariaDB default port
EXPOSE 3306

# Add MariaDB deamon
RUN mkdir -p /etc/service/mariadb/config
ADD service/mariadb/mariadb.sh /etc/service/mariadb/run
ADD service/mariadb/config /etc/service/mariadb/config

# Clear out the local repository of retrieved package files
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
