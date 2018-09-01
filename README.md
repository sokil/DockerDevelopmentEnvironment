# Docker Development Environment

This tool is a builder of development environment including PHP-FPM, MySQL and Nginx, and [other usefull tools](#available-services).
I'ts just a bunch of configurations, so you can freely change them for you needs.
It's also pre configured, so you need only place your files in sources directory and run container.
Entry point to work with container is `run` which wraps `docker-compose` and
pass some configuration together, allowing single place of configuration in `.env` file.

You say, hey, but we already have http://laradock.io/. And my answer is: yes, i know. Already know... ;)

## Create project

To create new project just clone this repository. Then you may change some variables in `.env` and run container through `run`.

By default your project placed in `./src` directory.

You can clone this repository to some folder inside your project, an reconfigure prameter `SRC_DIR` in `.env`.

## Configuration

All configs may be tuned through environment variables placed in `.env` file,
but you can add configuration in any way in any place. Explanation of environment variables is inside `.env`.

| Configuration parameter | Description                                                                              |
| ----------------------- | ---------------------------------------------------------------------------------------- |
| COMPOSE_PROJECT_NAME    | Name of project. Used as hostname of project and docker's project names                  |
| SRC_DIR                 | Relative path on host machine to project directory relativery to `.env`                  |
| SRC_DOCUMENT_ROOT       | Relative path on container machine to web server's document root relatively to `SRC_DIR` |
| PHP_APP_ENTRYPOINT      | Path to app entrypoint file relatively to `SRC_DOCUMENT_ROOT`, used by Nginx proxy       |

Example for `Symfony` project in `/var/www/server` with `.env` config in `/var/www/server/docker/.env`:
```
COMPOSE_PROJECT_NAME=someproject
SRC_DIR=..
SRC_DOCUMENT_ROOT=web
PHP_APP_ENTRYPOINT=app.php
```
After running project may be accessible in browser by address `http://someproject`.


## Managing container

Container managed through `run` command.

```
$ ./run
Available commands:
bash [service_name]: launch bash in some service container as root
php: launch php bash as www-user in container
mysql: launch mysql in container
Any commands not in list above goes directly to docker-compose, so be free to use this tool as docker-compose
```

This tool is just `docker-compose` with passed service configurations. So any commands of `docker-compose` may be passed to `run`. 

For example to build containers, run:
```
$ run up -d
```

To stop containers, run:
```
$ run stop
```

Also available additional commands.

To open php shell with www-data user in container, run:
```
$ run php
```

To open mysql console in container, run:
```
$ run mysql
```

To open bash in any container, run:
```
$ run bash nginx
```

## SSL

Cervificates placed in `./compose/nginx/ssl/` and may be regenerated by `./compose/nginx/ssl/gen_crt_quick.sh`.

## Available services

* elasticsearch
* memcached
* mysql
* nginx
* php
* postgresql
* rabbitmq
* redis
* mongodb

### MySQL

Database, user and password equals to `COMPOSE_PROJECT_NAME`. Hostname equals to ${COMPOSE_PROJECT_NAME}_mysql

### PHP

Uncomment node and grunt sections at `./compose/php/entrypoint.sh` if you require it.

#### Debugging with XDebug

PHP container pre configured to debug web sessions and console applications.
PHP will send debug to host mashine on remote port `9001`.

To debug console app, use `xphp` tool:
```
$ xphp some.php
```

### PostgreSQL

Database, user and password equals to `COMPOSE_PROJECT_NAME`. Hostname equals to ${COMPOSE_PROJECT_NAME}_postgresql

## Integration

### Sentry

Add Sentry logging intergation with [DockerSentry](https://github.com/sokil/DockerSentry)
