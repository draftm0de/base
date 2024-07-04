## base images

Each service has to have (build) his own images.<br/>

On top, you need some BASE images. The base images will prepare you an image with

- all required application plugins (e.g. composer)
- all required operating system plugins (e.g. tzdata)

**_A base image does not include any content_**

Our base images are:

### webserver
- [Caddy](./caddy/README.md)
- [Nginx](./nginx/README.md)

### php
- [PHP-FPM](./php-fpm/README.md)

### database
- [Mariadb](./mariadb/README.md)
