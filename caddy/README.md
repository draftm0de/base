# caddy webserver
official page: https://caddyserver.com/

1. [Dockerfile](#dockerfile)
   1. [included packages](#included-packages)
   2. [prepared folder](#prepared-folder)
   3. [prepared files](#prepared-files)
   4. [steps/targets](#stepstargets)
   5. [build arguments](#build-arguments)
   6. [reserved ENV(s)](#reserved-envs)
2. [FAQ](#faq)
   1. [reload](#reload)
   2. [reverse proxy](#reverse-proxy)
   3. [php fpm (fastcgi)](#php-fpm-fastcgi)
   4. [environment variables](#environment-variables)

## Dockerfile
### included packages
- tzdata
- nss-tools
- curl

### prepared folder
- /etc/caddy/sites-enabled<br/>
_our CaddyFile import all files stored in this folder. We recommend to have, for each domain, a separate file within his server directives._<br/>

### prepared files
#### /etc/caddy/Caddyfile 
  - log
    - output => stdout 
    - level => ${LOG_LEVEL:ERROR}
    - format => ${LOG_FORMAT:json}
  - directive: import sites-enabled/*

### steps/targets
There are no steps provided.

### build arguments
- TIME_ZONE<br/>
_These argument is forwarded a ENV TZ to caddy (e.g. "Europe/Vienna"). 
Although caddy use TZ on runtime, we decided to provide this configuration in the base image._

### reserved ENV(s)
Dockerfiles using this base image can reuse already provided ENV variables.

**TZ**<br/>
_As mentioned, used to set a TZ for caddy._

**SITES_ENABLED_PATH**<br/>
_Our Caddyfile ``/etc/caddy/Caddyfile`` imports all files stored in /sites-enabled folder._

```
import sites-enabled/*
```

The PATH is delivered as an ENV SITES_ENABLED_PATH="/etc/caddy/sites-enabled"

**Dockerfile (Example)**
```
FROM draftmode/base.caddy:1.0.0

ARG SITES_ENABLED_PATH
COPY (your source folder) $SITES_ENABLED_PATH
```
**docker-compose.override.yml (Example)**
```
   volumes:
      - ./proxy/etc/caddy/sites-enabled/dev:/etc/caddy/sites-enabled
```

## FAQ
### reload
_running image via docker compose_
```
docker compose exec <container> caddy reload -c /etc/caddy/Caddyfile
```
### reverse proxy
#### implemented via docker compose 
When using caddy as a reverse proxy to another webserver (e.g. nginx based) there are **two things you have to know/share/determine**.

(1) the service you want to be addressed has to be in the **same network**<br/>
(2) the **service name** you want to address to has to be known by the proxy 
- docker-compose.yml (proxy)
  ```
  services:
      proxy:
          networks:
              - proxy
                
  networks:
      proxy:
          name: proxy
  ```
- docker-compose.yml (other webserver)
  ```
  services:
      webserver:
          container_name: containertobeaddressed
          networks:
              - proxy
                
  networks:
      proxy:
          external: true
  ```
- caddy config<br/>
_(stored in /etc/caddy/sites-enabled/draftmode.io)_
    ```
    www.draftmode.io {
        reverse_proxy / http://containertobeaddressed
    }
    ```
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
