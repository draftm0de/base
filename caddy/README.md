# caddy webserver
official page: https://caddyserver.com/

1. [build arguments](#build-arguments)
2. [compressed knowledge](#compressed-knowledge)
   1. [php fpm](#php-fpm-fastcgi)
   2. [using environment variables](#using-environment-variables)

## build arguments

Our base image additional includes
- tzdata _(required to set up time zone)_
- nss-tools _(required to create ssl certificates)_
- curl

### Timezone
- TZ

_notice:<br/>
Although caddy use TZ on runtime, we decided to provide the configuration in the base image.<br/>
Our understanding of responsibility: developers are not responsible for the Timezone.<br/>But, it is also possible to set TZ via docker-compose.yml._

## compressed knowledge
### php fpm (fastcgi)
[Documentation](https://caddyserver.com/docs/caddyfile/directives/php_fastcgi)

In every case you have to define
- **root (e.g. /var/app)**
- **php_fastcgi (e.g. unix//socket/php.fpm)**

_example:_ 
```
api.dev.demo.io {
    tls internal
    root * /var/app
    php_fastcgi unix//socket/php.fpm
    rewrite * /index.php
}
```
#### proxy via socket
_example:_
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
_example:_
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
### using environment variables
caddy, out of the box, supports usage of environment arguments.

_example:_
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
