#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

if [ -f "composer.json" ]; then
    composer install --prefer-dist --no-progress --no-interaction
fi

exec docker-php-entrypoint "$@"