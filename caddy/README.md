# caddy webserver
official page: https://caddyserver.com/

1. [steps](#steps)
2. [provided environment arguments](#provided-environment-arguments)
3. [arguments](#build-arguments)
4. [compressed knowledge](#compressed-knowledge)
   1. [php fpm](#php-fpm-fastcgi)
   2. [environment variables](#environment-variables)

## steps
For caddy there are no steps provided. 

## provided environment arguments
Dockerfiles using this base image can reuse already provided ENV variables.

_docker-compose(.override).yml:_<br/>
**keep in mind that ENV variables provided in the base image cannot be used in a docker-compose(.override).yml context.**

### SITES_ENABLED_PATH
Our Caddyfile ``/etc/caddy/Caddyfile`` includes all host configuration files by importing all files in sites-enabled folder.<br/>
_The method is comparable with nginx site-enabled._<br/>
```
import sites-enabled/*
```

The target PATH is delivered as an ENV SITES_ENABLED_PATH="/etc/caddy/sites-enabled"
#### Dockerfile
_Example:_
```
FROM draftmode/base.caddy:1.0.0

ARG SITES_ENABLED_PATH
COPY (your source folder) $SITES_ENABLED_PATH
```
#### docker-compose.override.yml
_Example:_
```
   volumes:
      - ./proxy/etc/caddy/sites-enabled/dev:/etc/caddy/sites-enabled
```

## build arguments

Our base image additional includes
- tzdata _(required to set up time zone)_
- nss-tools _(required to create ssl certificates)_
- curl

### Timezone
- TZ

_Notice:_<br/>
_Although caddy use TZ on runtime, we decided to provide the configuration in the base image.<br/>
Our understanding of responsibility: developers are not responsible for the Timezone.<br/>But, it is also possible to set TZ via docker-compose.yml._

## compressed knowledge
### php fpm (fastcgi)
[Documentation](https://caddyserver.com/docs/caddyfile/directives/php_fastcgi)

In every case you have to define
- **root (e.g. /var/app)**
- **php_fastcgi (e.g. unix//socket/php.fpm)**

_Example:_ 
```
api.dev.demo.io {
    tls internal
    root * /var/app
    php_fastcgi unix//socket/php.fpm
    rewrite * /index.php
}
```
#### proxy via socket
_Example:_
```
api.dev.demo.io {
    tls internal
    root * /var/app
    php_fastcgi unix//socket/php.fpm
    rewrite * /index.php
}
```
_docker-compose.yml:_<br>
You have to have a shared volume to share the socket file.<br/>
And for sure PHP-FPM has to listen to the socket file.
```
services:
    webserver:
        volumes:
            sockets:/socket/php.fpm            
    php:
        volumes:
            sockets:/socket/php.fpm
volumes:
    sockets:
```
#### proxy via port
The webserver has to have access (network based) to the related service.<br/>
```
php_fastcgi [container]:[port]
```
_Example:_
```
api.dev.demo.io {
    tls internal
    root * /var/app
    php_fastcgi php:9000
    rewrite * /index.php
}
```
_docker-compose.yml:_
```
services:
    webserver:
    php:
```
### environment variables
Caddy, out of the box, supports usage of environment arguments.

_Example:_
```
-------------------------------
docker-compose.yml
-------------------------------
services:
  webserver:
    environment:
      ROOT_FOLDER: my/root/folder

-------------------------------
/etc/caddy/Caddyfile
-------------------------------
www.dev.demo.io {
    tls internal
    root * {$ROOT_FOLDER}
    file_server
}
```
