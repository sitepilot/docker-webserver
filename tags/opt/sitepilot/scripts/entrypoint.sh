#!/bin/sh
set -e 

log() {
    echo "[INFO] $1"
}

log "Generating configuration files..."
sed -i -e "s~{PHP_VERSION}~${PHP_VERSION}~" \
    -e "s~{MAIL_RELAY_PORT}~${MAIL_RELAY_PORT}~" \
    /usr/local/lsws/conf/httpd_config.conf

sed -i -e "s~{MAIL_RELAY_PORT}~${MAIL_RELAY_PORT}~" \
    -e "s~{MAIL_RELAY_HOST}~${MAIL_RELAY_HOST}~" \
    -e "s~{MAIL_RELAY_USER}~${MAIL_RELAY_USER}~" \
    -e "s~{MAIL_RELAY_PASS}~${MAIL_RELAY_PASS}~" \
    /etc/msmtprc

log "Updating user ID, GID and name..."
usermod -u $USER_ID $USER_NAME
groupmod -g $USER_GID $USER_NAME

log "Updating file permissions..."
chown -R $USER_NAME:$USER_NAME /opt/sitepilot/site

log "Done!"

exec "$@"