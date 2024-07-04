# ---------------------------------------------------------------
# production stage
# ---------------------------------------------------------------
ARG IMAGE_NAME
FROM ${IMAGE_NAME} AS production

ARG WORK_DIR
ARG TIME_ZONE
ARG WWW_LISTEN=9000
ARG WWW_USER=www-data
ARG WWW_GROUP=www-data
ARG WWW_PM=dynamic
ARG WWW_PM_MAX_CHILDREN=5
ARG WWW_PM_START_SERVERS=2
ARG WWW_PM_MIN_SPARE_SERVERS=1
ARG WWW_PM_MAX_SPARE_SERVERS=3

ENV TZ=${TIME_ZONE}
ENV WWW_LISTEN=${WWW_LISTEN}
ENV WWW_USER=${WWW_USER}
ENV WWW_GROUP=${WWW_GROUP}
ENV WWW_PM=${WWW_PM}
ENV WWW_PM_MAX_CHILDREN=${WWW_PM_MAX_CHILDREN}
ENV WWW_PM_START_SERVERS=${WWW_PM_START_SERVERS}
ENV WWW_PM_MIN_SPARE_SERVERS=${WWW_PM_MIN_SPARE_SERVERS}
ENV WWW_PM_MAX_SPARE_SERVERS=${WWW_PM_MAX_SPARE_SERVERS}

# internal folders
ENV DOCKER_BIN_PATH=/usr/local/bin
ENV PHP_FPM_PATH=/usr/local/etc/php-fpm.d
ENV PHP_CONF_PATH=/usr/local/etc/php/conf.d

ENV APK_ADD_NO_CACHE \
# optional: like bash more than sh
    bash \
# optional: i like nano more than vim
    nano \
# required to set timezone
    tzdata

ENV PHP_EXTENSIONS \
    pdo \
    pdo_mysql

# --- provide custom healthcheck ---
COPY $DOCKER_BIN_PATH/docker-healthcheck.sh /usr/local/bin/docker-healthcheck
# --- default configurations for php-fpm.d and conf.d
COPY $PHP_FPM_PATH $PHP_FPM_PATH
COPY $PHP_CONF_PATH $PHP_CONF_PATH

RUN apk add --update --no-cache ${APK_ADD_NO_CACHE} \
 && apk upgrade --available \
 && docker-php-ext-install ${PHP_EXTENSIONS} \
# --- remove default php-fpm.d/conf --- \
 && rm -f $PHP_FPM_PATH/zz-docker.conf \
 && rm -f $PHP_FPM_PATH/www.conf.default \
 && rm -f $PHP_FPM_PATH/www.conf \
# --- add date.timezone to php conf ---
 && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
 # --- make custom scripts executable ---
 && chmod +x /usr/local/bin/docker-healthcheck

WORKDIR $WORK_DIR

# ---------------------------------------------------------------
# dev stage
# ---------------------------------------------------------------
FROM production AS dev

ARG XDEBUG_CLIENT_PORT=9003
ENV XDEBUG_CLIENT_PORT=${XDEBUG_CLIENT_PORT}
ARG XDEBUG_CLIENT_HOST=host.docker.internal
ENV XDEBUG_CLIENT_HOST=${XDEBUG_CLIENT_HOST}
ARG XDEBUG_MODE=debug
ENV XDEBUG_MODE=${XDEBUG_MODE}

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# --- provide custom entry point ---
COPY $DOCKER_BIN_PATH/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN apk add --no-cache linux-headers \
 && apk add --update --no-cache --virtual .build-dependencies $PHPIZE_DEPS \
 && pecl install xdebug \
 && docker-php-ext-enable xdebug \
 && pecl clear-cache \
 && apk del .build-dependencies \
 && chmod +x /usr/local/bin/docker-entrypoint.sh

# ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]