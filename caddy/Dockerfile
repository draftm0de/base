ARG IMAGE_NAME
FROM ${IMAGE_NAME}

ARG TIME_ZONE
ENV TZ=${TIME_ZONE}

ENV APK_ADD \
    tzdata \
    nss-tools \
    curl

RUN apk add --update --no-cache ${APK_ADD} \
 && mkdir /etc/caddy/sites-enabled

COPY /etc/caddy/Caddyfile /etc/caddy/Caddyfile
