# database mariadb
official page: https://mariadb.org/

1. [build arguments](#build-arguments)

## build arguments

### Timezone
- TZ

_notice:<br/>
Although caddy use TZ on runtime, we decided to provide the configuration in the base image.<br/>
Our understanding of responsibility: developers are not responsible for the Timezone.<br/>But, it is also possible to set TZ via docker-compose.yml._
