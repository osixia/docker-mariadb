# osixia/mariadb

[![](https://badge.imagelayers.io/osixia/mariadb:latest.svg)](https://imagelayers.io/?images=osixia/mariadb:latest 'Get your own badge on imagelayers.io') | Latest release: 0.2.9 - MariaDB 10.1.10 - [Changelog](CHANGELOG.md) | [Docker Hub](https://hub.docker.com/r/osixia/mariadb/) 

A docker image to run a MariaDB server.
> [wikipedia.org/wiki/MariaDB](https://en.wikipedia.org/wiki/MariaDB)

## Quick start
Run MariaDB docker image:

	docker run --name my-mariadb-container --detach osixia/mariadb:0.2.9

This start a new container with a MariaDB server running inside.

First we run a terminal on this container:

	docker exec -it my-mariadb-container bash

You should now be in the container terminal,
to properly use this terminal we need to fix the TERM environment variable :

	export TERM=xterm

We can now connect to the MariaDB server using mysql command line tool :

	mysql -u admin -padmin


## Beginner Guide

### Create new database
This is the default behavior when you run the image.

It will create an empty database, with a root and a debian-sys-maint user (required by MariaDB to run properly on debian).
The default root username (admin) and password (admin) can be changed at the docker command line, for example :

	docker run --env MARIADB_ROOT_USER=JaxTeller --env MARIADB_ROOT_PASSWORD=SonsOfAnarchy --detach osixia/mariadb

For security reasons, by default the root user can only login to MariaDB from local networks.
This can also be changed at the docker command line.

For example if you want to allow MariaDB root login from docker default network and localhost :

	docker run --env MARIADB_ROOT_ALLOWED_NETWORKS="#PYTHON2BASH:['172.17.%.%', 'localhost', '127.0.0.1', '::1']" \
	--detach osixia/mariadb


#### Full example
This example will run a docker MariaDB container and execute an sql query from docker host:

	CONTAINER_ID=$(docker run --env MARIADB_ROOT_USER=JaxTeller \
		--env MARIADB_ROOT_PASSWORD=SonsOfAnarchy \
		--env MARIADB_ROOT_ALLOWED_NETWORKS="#PYTHON2BASH:['172.17.%.%', 'localhost', '127.0.0.1', '::1']" \
		--detach osixia/mariadb)

	CONTAINER_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" $CONTAINER_ID)

	mysql -u JaxTeller -pSonsOfAnarchy -h $CONTAINER_IP -e "select user,host from mysql.user"


#### Data persistence

The directory `/var/lib/mysql` (witch contains all MariaDB database files) has been declared as a volume, so your database files are saved outside the container in a data volume.

For more information about docker data volume, please refer to :

> [https://docs.docker.com/userguide/dockervolumes/](https://docs.docker.com/userguide/dockervolumes/)

### Use an existing MariaDB database

This can be achieved by mounting a host directory as volume.
Assuming you have a MariaDB database on your docker host in the directory `/data/mariadb/CoolDb`
simply mount this directory as a volume to `/var/lib/mysql` :

	docker run --volume /data/mariadb/CoolDb:/var/lib/mysql \
	--env MARIADB_ROOT_USER=MyCoolDbRootUser \
	--env MARIADB_ROOT_PASSWORD=MyCoolDbRootPassword \
	--detach osixia/mariadb

You can also use data volume containers. Please refer to :
> [https://docs.docker.com/userguide/dockervolumes/](https://docs.docker.com/userguide/dockervolumes/)

### Use a custom my.cnf

Add your custom **my.cnf** in the directory **image/service/mariadb/assets** and rebuild the image ([see manual build](#manual-build)).

Or you can set your custom config at run time, by mouting your **my.cnf** file to **/container/service/mariadb/assets/my.cnf**

	docker run --volume /path/to/my.cnf:/container/service/mariadb/assets/my.cnf --detach osixia/mariadb

### SSL

#### Use autogenerated certificate
By default SSL is enable, a certificate is created with the container hostname (it can be set by docker run --hostname option eg: phpldapadmin.my-company.com).

	docker run --hostname db.my-company.com --detach osixia/mariadb:0.2.9

#### Use your own certificate

You can set your custom certificate at run time, by mounting a directory containing those files to **/container/service/mariadb/assets/certs** and adjust their name with the following environment variables:

	docker run --volume /path/to/certifates:/container/service/mariadb/assets/certs \
	--env MARIADB_SSL_CRT_FILENAME=my-cert.crt \
	--env MARIADB_SSL_KEY_FILENAME=my-cert.key \
	--env MARIADB_SSL_CA_CRT_FILENAME=the-ca.crt \
	--detach osixia/mariadb:0.2.9

Other solutions are available please refer to the [Advanced User Guide](#advanced-user-guide)

#### Disable SSL
Add --env MARIADB_SSL=false to the run command :

    docker run --env MARIADB_SSL=false --detach osixia/mariadb:0.2.9

### Debug

The container default log level is **info**.
Available levels are: `none`, `error`, `warning`, `info`, `debug` and `trace`.

Example command to run the container in `debug` mode:

	docker run --detach osixia/mariadb:0.2.9 --loglevel debug

See all command line options:

	docker run osixia/mariadb:0.2.9 --help


## Environment Variables

Environment variables defaults are set in **image/environment/default.yaml**

See how to [set your own environment variables](#set-your-own-environment-variables)

Required for uninitialized and initialized database :
- **MARIADB_ROOT_USER**: The database root username. Defaults to `admin`
- **MARIADB_ROOT_PASSWORD**: The database root password. Defaults to `admin`

Required only for uninitialized database
- **MARIADB_ROOT_ALLOWED_NETWORKS**: root login will only be allowed from those networks. Defaults to:
	```yaml
	- localhost
  - 127.0.0.1
  - ::1
	```
	If you want to set this variable at docker run command add the tag `#PYTHON2BASH:` and convert the yaml in python:

		docker run --env PHPLDAPADMIN_LDAP_HOSTS="#PYTHON2BASH:['localhost','127.0.0.1','::1']" --detach osixia/mariadb:0.2.9

	To convert yaml to python online: http://yaml-online-parser.appspot.com/


Backup :

- **MARIADB_BACKUP_USER**: The database backup user username. Defaults to `backup`
- **MARIADB_BACKUP_PASSWORD**: The database backup user password. Defaults to `backup`

- **MARIADB_BACKUP_CRON_EXP**: Cron expression to schedule data backup. Defaults to `"0 4 * * *"`. Every days at 4am.

- **MARIADB_BACKUP_TTL**: Backup TTL in days. Defaults to `15`.

SSL :

- **MARIADB_SSL**: Enable ssl. Defaults to `true`
- **MARIADB_SSL_CIPHER_SUITE**: TLS cipher suite. Defaults to `TLSv1.2`
- **MARIADB_SSL_CRT_FILENAME**: MariaDB ssl certificate filename. Defaults to `mariadb.crt`
- **MARIADB_SSL_KEY_FILENAME**: MariaDB ssl certificate private key filename. Defaults to `mariadb.key`
- **MARIADB_SSL_CA_CRT_FILENAME**: MariaDB ssl CA certificate filename. Defaults to `ca.crt`

	More information at : https://mariadb.com/kb/en/mariadb/ssl-system-variables/

Other environment variables:
- **MARIADB_CFSSL_PREFIX**: cfssl environment variables prefix. Defaults to `database`, cfssl-helper first search config from DATABASE_CFSSL_* variables, before CFSSL_* variables.


### Set environment variables at run time :

String environment variable can be set directly by adding the --env argument in the command line, for example :

	docker run --env MARIADB_ROOT_USER="JaxTeller" --env MARIADB_ROOT_PASSWORD="Sons Of Anarchy" --detach osixia/mariadb

For more complex environment variables like ROOT_ALLOWED_NETWORKS there value must be set in python.
As you can see in **image/env.yaml** the variable ROOT_ALLOWED_NETWORKS is a list of network adresses :

	  - localhost
	  - 127.0.0.1
	  - ::1

So if we want to set this environement variable at run time, first we convert it to a python string (use [this tool](http://yaml-online-parser.appspot.com/) for example), it become :

	['localhost', '127.0.0.1', '::1']

Then we run the image by adding the the --env argument with the python string :

	docker run --env ROOT_ALLOWED_NETWORKS="['localhost', '127.0.0.1', '::1']" --detach osixia/mariadb

You can also set your own `env.yaml` file as a docker volume to `/container/environment/env.yaml`

		docker run --volume /data/my-env.yaml:/container/environment/env.yaml \
		--detach osixia/mariadb


### Set your own environment variables

#### Use command line argument
Environment variables can be set by adding the --env argument in the command line, for example:

	docker run --env MARIADB_ROOT_USER="JaxTeller" --env MARIADB_ROOT_PASSWORD="Sons Of Anarchy" --detach osixia/mariadb:0.2.9

#### Link environment file

For example if your environment file is in :  /data/environment/my-env.yaml

	docker run --volume /data/environment/my-env.yaml:/container/environment/01-custom/env.yaml \
	--detach osixia/mariadb:0.2.9

Take care to link your environment file to `/container/environment/XX-somedir` (with XX < 99 so they will be processed before default environment files) and not  directly to `/container/environment` because this directory contains predefined baseimage environment files to fix container environment (INITRD, LANG, LANGUAGE and LC_CTYPE).

#### Make your own image or extend this image

This is the best solution if you have a private registry. Please refer to the [Advanced User Guide](#advanced-user-guide) just below.

## Advanced User Guide

### Extend osixia/mariadb:0.2.9 image

If you need to add your custom TLS certificate, bootstrap config or environment files the easiest way is to extends this image.

Dockerfile example:

    FROM osixia/mariadb:0.2.9
    MAINTAINER Your Name <your@name.com>

    ADD ssl-certs /container/service/mariadb/assets/certs
    ADD my.cnf /container/service/mariadb/assets/my.cnf
    ADD environment /container/environment/01-custom


### Make your own phpLDAPadmin image


Clone this project :

	git clone https://github.com/osixia/docker-mariadb
	cd docker-mariadb

Adapt Makefile, set your image NAME and VERSION, for example :

	NAME = osixia/mariadb
	VERSION = 0.2.9

	becomes :
	NAME = billy-the-king/mariadb
	VERSION = 0.1.0

Add your custom certificate, environment files, my.cnf ...

Build your image :

	make build

Run your image :

	docker run --detach billy-the-king/mariadb:0.1.0

### Tests

We use **Bats** (Bash Automated Testing System) to test this image:

> [https://github.com/sstephenson/bats](https://github.com/sstephenson/bats)

Install Bats, and in this project directory run :

	make test

### Kubernetes

Kubernetes is an open source system for managing containerized applications across multiple hosts, providing basic mechanisms for deployment, maintenance, and scaling of applications.

More information:
- http://kubernetes.io
- https://github.com/kubernetes/kubernetes

A kubernetes example is available in **example/kubernetes**

### Under the hood: osixia/light-baseimage

This image is based on osixia/light-baseimage.
More info: https://github.com/osixia/docker-light-baseimage

## Changelog

Please refer to: [CHANGELOG.md](CHANGELOG.md)
