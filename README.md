# osixia/mariadb

A docker image to run a MariaDB server.
> [wikipedia.org/wiki/MariaDB](https://en.wikipedia.org/wiki/MariaDB)

## Quick start
Run MariaDB docker image :

	docker run -d osixia/mariadb

This start a new container with a MariaDB server running inside.
The odd string printed by this command is the `CONTAINER_ID`.
We are going to use this `CONTAINER_ID` to execute some commands inside the container.

First we run a terminal on this container,
make sure to replace `CONTAINER_ID` by your container id : 

	docker exec -it CONTAINER_ID bash

You should now be in the container terminal, 
to properly use this terminal we need to fix the TERM environment variable :

	export TERM=xterm

We can now connect to the MariaDB server using mysql command line tool :
	
	mysql -u admin -padmin


## Examples

### Create new database
This is the default behaviour when you run the image.

It will create an empty database, with a root and a debian-sys-maint user (required by MariaDB to run properly on ubuntu).
The default root username (admin) and password (admin) can be changed at the docker command line, for example :

	docker run -e ROOT_USER=JaxTeller -e ROOT_PWD=SonsOfAnarchy -d osixia/mariadb

For security reasons, by default the root user can only login to MariaDB from local networks.
This can also be changed at the docker command line.

For example if you want to allow MariaDB root login from docker default network and localhost :

	docker run -e ROOT_ALLOWED_NETWORKS="['172.17.%.%', 'localhost', '127.0.0.1', '::1']" \
	-d osixia/mariadb


#### Full example
This example will run a docker MariaDB container and execute an sql query from docker host:

	CONTAINER_ID=$(docker run -e ROOT_USER=JaxTeller \
		-e ROOT_PWD=SonsOfAnarchy \
		-e ROOT_ALLOWED_NETWORKS="['172.17.%.%', 'localhost', '127.0.0.1', '::1']" \
		-d osixia/mariadb)

	CONTAINER_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" $CONTAINER_ID)

	mysql -u JaxTeller -pSonsOfAnarchy -h $CONTAINER_IP -e "select user,host from mysql.user"


#### Data persitance

The directory `/var/lib/mysql` (witch contains all MariaDB database files) has been declared as a volume, so your database files are saved outside the container in a data volume.

This mean that you can stop, and restart the container and get back your database without losing any data. But if you remove the container, the data volume will me removed too, except if you have linked this data volume to an other container.

For more information about docker data volume, please refer to :

> [https://docs.docker.com/userguide/dockervolumes/](https://docs.docker.com/userguide/dockervolumes/)

### Use an existing MariaDB database

This can be achieved by mounting a host container as data volume. 
Assuming you have a MariaDB database on your docker host in the directory `/data/mariadb/CoolDb`
simply mount this directory as a volume to `/var/lib/mysql` :

	docker run -v /data/mariadb/CoolDb:/var/lib/mysql \
	-e ROOT_USER=MyCoolDbRootUser \
	-e ROOT_PWD=MyCoolDbRootPassword \
	-d osixia/mariadb

You can also use data volume containers. Please refer to :
> [https://docs.docker.com/userguide/dockervolumes/](https://docs.docker.com/userguide/dockervolumes/)

## Environment Variables

Environement variables defaults are set in **image/env.yml**. You can modify environment variable values directly in this file and rebuild the image ([see manual build](#manual-build)) or you can override those values at run time with -e argument but they must be converted as python string. See example below.

Required for uninitialized and initialized database :
- **ROOT_USER**: The database root username. Defaults to `admin`
- **ROOT_PWD**: The database root password. Defaults to `admin`

Required only for uninitialized database :
- **ROOT_ALLOWED_NETWORKS**: root login will only be allowed from those networks. Defaults to `['localhost', '127.0.0.1', '::1']`

### Set environment variable at run time :

String environment variable can be set directly by adding the -e argument in the command line, for example :
	
	docker run -e ROOT_USER="JaxTeller" -e ROOT_PWD="Sons Of Anarchy" -d osixia/mariadb

For more complex environment variable like ROOT_ALLOWED_NETWORKS there value must be set in python.
As you can see in **image/env.yml** the variable ROOT_ALLOWED_NETWORKS is a list of network adresses :

	  - localhost
	  - 127.0.0.1
	  - ::1

So if we want to set this environement variable at run time, first we convert it to a python string (use [this tool](http://yaml-online-parser.appspot.com/) for example), it become :

	['localhost', '127.0.0.1', '::1']

Then we run the image by adding the the -e argument with the python string :

	docker run -e ROOT_ALLOWED_NETWORKS="['localhost', '127.0.0.1', '::1']" -d osixia/mariadb

## Manual build

Clone this project :

	git clone https://github.com/osixia/docker-mariadb
	cd docker-mariadb

Adapt Makefile, set your image NAME and VERSION, for example :

	NAME = osixia/mariadb
	VERSION = 0.2.4
	
	becomes :
	NAME = billy-the-king/mariadb
	VERSION = 0.1.0

Build your image :
	
	make build
	
Run your image :

	docker run -d billy-the-king/mariadb:0.1.0
	
### Use custom my.cnf

Add your custom **my.cnf** in the directory **image/service/mariadb/assets** and rebuild the image.

Note: you can also use your custom config at run time, mount your **my.cnf** file to **/etc/mysql/my.cnf**

	docker run -v /path/to/my.cnf:/etc/mysql/my.cnf -d osixia/mariadb

## Tests

We use **Bats** (Bash Automated Testing System) to test this image:

> [https://github.com/sstephenson/bats](https://github.com/sstephenson/bats)

Install Bats, and in this project directory run :

	make test

