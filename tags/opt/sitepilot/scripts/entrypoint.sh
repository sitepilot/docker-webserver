#!/bin/sh
set -e 

log() {
    echo "[ENTRYPOINT] $1"
}

log "Generating configuration files."
sed -i -e "s~{PHP_VERSION}~${BUILD_PHP_VERSION}~" \
    -e "s~{MAIL_RELAY_PORT}~${MAIL_RELAY_PORT}~" \
    /usr/local/lsws/conf/httpd_config.conf

sed -i -e "s~{MAIL_RELAY_PORT}~${MAIL_RELAY_PORT}~" \
    -e "s~{MAIL_RELAY_HOST}~${MAIL_RELAY_HOST}~" \
    -e "s~{MAIL_RELAY_USER}~${MAIL_RELAY_USER}~" \
    -e "s~{MAIL_RELAY_PASS}~${MAIL_RELAY_PASS}~" \
    /etc/msmtprc

log "Updating file permissions."
chown -R $BUILD_USER_NAME:$BUILD_USER_NAME /opt/sitepilot/app

log "Removing sudo privileges."
sed -i '$ d' /etc/sudoers

log "Done!"

exec "$@"