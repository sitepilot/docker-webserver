#!/bin/sh
set -e 

log() {
    echo "[INFO] $1"
}

log "Generating configuration files..."
sed -i -e "s~{PHP_VERSION}~${PHP_VERSION}~" \
    /usr/local/lsws/conf/httpd_config.conf

log "Updating user ID, GID and name..."
usermod -u $USER_ID $USER_NAME
groupmod -g $USER_GID $USER_NAME

log "Updating file permissions..."
chown -R $USER_NAME:$USER_NAME /opt/sitepilot/site

log "Done!"

exec "$@"