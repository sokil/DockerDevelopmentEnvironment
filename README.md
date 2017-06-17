# Docker PHP Bootstrap

This tool is a builder of development environment including PHP-FPM, MySQL and Nginx.
I'ts just a bunch of configurations, so you can freely change them for you needs.
It's also pre configured, so you need only place your files in sources directory and run container.
Entry point to work with container id `run.sh` which wraps `docker-container` and
pass some configuration together, allowing single place of configuration in `.env` file.

## Create project

To create new project just clone this repository anywhere, and place you code to `./src` directory.
Then you may change some variables, if need` in `.env` file and run container through `run.sh`.

## Configuration

All configs may be tuned through environment variables, placed in '.env' file,
but you can add configuration in any way in any place. All parameters documented there.

## Managing container

Container management done through `run.sh`.

```
$ ./run.sh
Invalid command specified
Available commands:
bash [service_name]: launch bash in some service container
shell_php: launch bash as www-user in container
shell_mysql: launch mysql in container
Any commands not in list above goes directly to docker-compose, so be free to use this tool as docker-compose
```

This tool is just `docker-compose` with passed service configurations.
So any commands of `docker-compose` may be passed to `run.sh`.

To build container, run:

```
$ run.sh up -d
```

To open php shell with www-data user in container, run:

```
$ run.sh shell_php
```

To open mysql console in container, run:

```
$ run.sh shell_mysql
```

To open bash in any container, run:

```
$ run.sh bash nginx
```

To stop container, run:

```
$ run.sh stop
```
