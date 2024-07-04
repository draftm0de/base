# PHP-FPM
our current base-images uses ``php:8.2-fpm-alpine``

1. [stages](#stages)
2. [build arguments](#build-arguments)
3. [compressed knowledge](#compressed-knowledge)
   1. [php fpm listen](#php-fpm-listen)
   2. [Healthcheck](#healthcheck)

## stages
- production
- dev [_identical to production_] but additional with
  - php composer 
  - xdebug

## build arguments
Our base image additional includes
- tzdata _(required to set up time zone)_
- bash
- nano

Build arguments:
- WORK_DIR _**(required)**_
- TIME_ZONE _**(required)**_
- WWW_LISTEN _(default: 9000)_
- WWW_USER _(default: www-data)_
- WWW_GROUP _(default: www-data)_
- WWW_PM _(default: dynamic)_
- WWW_PM_MAX_CHILDREN _(default: 5)_
- WWW_PM_START_SERVERS _(default: 2)_
- WWW_PM_MIN_SPARE_SERVERS _(default: 1)_
- WWW_PM_MAX_SPARE_SERVERS _(default: 3)_

## compressed knowledge
Customized PHP (ini/conf) files are created prefixed with ``zz.{what.ever}.{ini/conf}``<br>
Prefixed with {zz.} because we want our customizations being included at the end to overwrite previous ones.

### php-fpm listen
In default the used image (php:8.2-fpm-alpine) expose port 9000.<br>
That means your ``docker compose ps`` will always show you 9000/tcp.
```
NAME                IMAGE             COMMAND                  SERVICE     CREATED         STATUS         PORTS
caddy-php-1         caddy-php         "docker-php-entrypoi…"   php         3 seconds ago   Up 3 seconds   9000/tcp
```
**but**<br/>
only the [www] listen = {} directive is on what PHP-FPM is listening
- there is no need to set up any EXPOSE directive in your docker-compose.yml
- there is no need to set up any EXPOSE directive in your Dockerfile
- there is no need to set up any PORT directive in your docker-compose.yml

#### php-fpm listen on a port
set WWW_LISTEN to e.g. 9090, that´s it.<br/>
Make sure, that your webserver (e.g. caddy) has to have access to the php container (same network).

_docker-compose_:
```
services:
  webserver:
  php:
```
_php-fpm directive for **[www]** listen will look like:_
```
[www]
listen=9003
```
#### php-fpm listen on a socket
set WWW_LISTEN to e.g. (sock/docker.socket).<br/>
Make sure, that both services (webserver and php) share a volume.

_docker-compose_:
```
services:
  webserver:
    volumes:
      - sockets:/socket/docker.fpm
  php:
    volumes:
      - sockets:/socket/docker.fpm
volumes:
  sockets:
```
_php-fpm directive for **[www]** listen will look like:_
```
[www]
listen=unix://socket/docker.fpm
; hack to share socket file between different users / groups
listen.mode = 0666
```

### Healthcheck
using */usr/local/bin/docker-healthcheck.sh* as already implemented
#### php-fpm listen on a port
--connect={PORT}<br><br>
example via docker-compose
```
    healthcheck:
      test: ["CMD", "docker-healthcheck", "-connect=9000"]
      interval: 10s
      timeout: 3s
      retries: 3
      start_period: 30s
```
#### php-fgm listen on a socket
--connect={SOCKET_FILE}<br><br>
example via docker-compose
```
    healthcheck:
      test: ["CMD", "docker-healthcheck", "-connect=unix:/socket/web.fpm"]
      interval: 10s
      timeout: 3s
      retries: 3
      start_period: 30s
```
