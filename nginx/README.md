# nginx webserver
official page: https://nginx.org/en/docs/

1. [steps](#steps)
2. [build arguments](#build-arguments)
3. [extensions](#extensions)
4. [compressed knowledge](#compressed-knowledge)
   1. [php fpm](#php-fpm-fastcgi)
   2. [nginx templates](#nginx-templates)

## steps
For mariadb there are no steps provided.

## build arguments

Our base image additional includes
- tzdata _(required to set up time zone)_
- bash
- nano

## extensions
in /etc/nginx/custom we provide a couple of conf/locations.

### deny.dotfolder.location
All . folders are denied.<br/>

_Notice_<br/>
_Take care about .well_known(*) folders. They are also exclude!_

_Example:_
```
server {
   include custom/deny.dotfolder.location;
}
```

### disable.robots.location
/robots.txt cannot be accessed.

_Example:_
```
server {
   include custom/disable.robots.location;
}
```

### ignore.favicon.location
/favicon.ico does not return a 404 if not present.

_Example:_
```
server {
   include custom/ignore.favicon.location;
}
```

### proxy.conf
Common location extension when using a proxy directive

_Example:_
```
server {
   location / {
      include custom/proxy.conf;
      proxy_pass http://127.0.0.1:8000; 
   }   
}
```

### resolver.conf
Add the default resolve for docker (127.0.0.11)

_Example:_
```
server {
   location / {
      include custom/resolver.conf;
       
   }   
}
```

### ssl.conf
When using any SSL communication, it's recommended to use these snippets, too.

_Example:_
```
server {
   location / {
      ssl on;
      ssl_certificate         /etc/ssl/your_domain_name.pem; (or bundle.crt)
      ssl_certificate_key     /etc/ssl/your_domain_name.key;
      include custom/ssl.conf;                   
   }   
}
```

### Timezone
- TZ

## compressed knowledge
### php fpm (fastcgi)

In every case you have to define
- **root (e.g. /var/app)**
- **php_fastcgi (e.g. unix://sockets/php.fpm)**

_Example:_
```
server {
    listen 80;
    server_name api.dev.demo.io;

    location / {
        include fastcgi_params;
        include custom/proxy.conf;
        fastcgi_pass unix://socket/php.fpm;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME /var/app/index.php;
    }
}
```
#### proxy via socket
_Example:_
```
location / {
    include fastcgi_params;
    include custom/proxy.conf;
    fastcgi_pass unix://socket/php.fpm;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME /var/app/index.php;
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
location / {
    include fastcgi_params;
    include custom/proxy.conf;
    fastcgi_pass php:9000;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME /var/app/index.php;
}
```
_docker-compose.yml:_
```
services:
    webserver:
    php:
```
### nginx templates
Using the default nginx (alpine), as we do, the nginx.conf includes /etc/nginx/conf.d/*.conf<br/>

Files located in /etc/nginx/templates are automatically converted with environment arguments and stored into /etc/nginx/conf.d/* when starting nginx.<br/>

_Example:_
```
docker-compose.yml
services:
  webserver:
    environment:
      ROOT_FOLDER: my/root/folder

/etc/nginx/templates/my.conf.template
server {
  root ${ROOT_FOLDER};
}

=> /etc/nginx/conf.d/my.conf
server {
  root my/root/folder;
}
```
#### changing the template
Changing the template files requires a new docker-compose up, cause the magic happens via docker-entrypoint(s).
