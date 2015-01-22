# docker-mariadb

A docker image to run a MariaDB server

## What is MariaDB?

MariaDB is a community-developed fork of the MySQL relational database
management system intended to remain free under the GNU GPL. Being a fork of a
leading open source software system, it is notable for being led by the original
developers of MySQL, who forked it due to concerns over its acquisition by
Oracle. Contributors are required to share their copyright with the MariaDB
Foundation.

The intent is also to maintain high compatibility with MySQL, ensuring a
"drop-in" replacement capability with library binary equivalency and exact
matching with MySQL APIs and commands. It includes the XtraDB storage engine for
replacing InnoDB, as well as a new storage engine, Aria, that intends to be both
a transactional and non-transactional engine perhaps even included in future
versions of MySQL.

> [wikipedia.org/wiki/MariaDB](https://en.wikipedia.org/wiki/MariaDB)

## Quick start
Run MariaDB docker image :

	docker run -d osixia/mariadb

This start a new container with a MariaDB server running inside.
The odd string printed by the command is the `CONTAINER_ID`.
We are going to use this `CONTAINER_ID` to execute some commands inside the container.

First we run a terminal on this container,
make sure to replace `CONTAINER_ID` by your container id : 

	docker exec -it CONTAINER_ID bash

You should now be in the container terminal, 
to properly use this terminal we need to fix the TERM environement variable :

	export TERM=xterm

We can now connect to the MariaDB server using mysql command line tool :
	
	mysql -u admin -padmin


## How to use this image

### Create new database
This is the default behaviour when you run the image.

It will create an empty database, with a root and a debian-sys-maint user (required by MariaDB to run properly on ubuntu).
The default root username and password can be changed at the docker command line, for example :

	docker run -e ROOT_USER=JaxTeller -e ROOT_PWD=SonsOfAnarchy -d osixia/mariadb

For security reasons, by default the root user can only login to MariaDB from local networks.
This can also be changed at the docker command line.

For example if you want to allow MariaDB root login from docker default network and localhost :

	docker run -e ROOT_ALLOWED_NETWORKS=172.17.%.%,localhost,127.0.0.1,::1 \
	-d osixia/mariadb


All variables can be combined :

	docker run -e ROOT_USER=JaxTeller \
	-e ROOT_PWD=SonsOfAnarchy \
	-e ROOT_ALLOWED_NETWORKS=172.17.%.%,localhost,127.0.0.1,::1 \
	-d osixia/mariadb


#### Full example
This example will run a docker MariaDB container and execute an sql query from docker host:

	CONTAINER_ID=$(docker run -e ROOT_USER=JaxTeller -e ROOT_PWD=SonsOfAnarchy -e ROOT_ALLOWED_NETWORKS=172.17.%.%,localhost,127.0.0.1,::1 -d osixia/mariadb)

	CONTAINER_IP=$(docker.io inspect -f "{{ .NetworkSettings.IPAddress }}" $CONTAINER_ID)

	mysql -u JaxTeller -pSonsOfAnarchy -h $CONTAINER_IP -e "select user,host from mysql.user"


### Using an existing MariaDB database

This can be achived by using docker volume capabilities.
Assuming you have a MariaDB database on your docker host in the directory /data/mariadb/

simply mount this volume to /var/lib/mysql :

	docker run -v 



## Data persitance


## Environment Variables

Needed for uninitialized and initialized database :
- **ROOT_USER**: The root username. Defaults to `admin`
- **ROOT_PWD**: The root password. Defaults to `admin`

Needed only for uninitialized database
- **ROOT_ALLOWED_NETWORKS**: root login will be allowed only from those networks. Defaults to `localhost,127.0.0.1,::1`