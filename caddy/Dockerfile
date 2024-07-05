ARG IMAGE_NAME
FROM ${IMAGE_NAME}

ARG TIME_ZONE
ENV TZ=${TIME_ZONE}

ENV APK_ADD \
    tzdata \
    nss-tools \
    curl

ENV SITES_ENABLED_PATH="/etc/caddy/sites-enabled"

RUN apk add --update --no-cache ${APK_ADD} \
 && mkdir ${SITES_ENABLED_PATH}

COPY /etc/caddy/Caddyfile /etc/caddy/Caddyfile
