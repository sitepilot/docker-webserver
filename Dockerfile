FROM bitnami/minideb:buster
LABEL maintainer "Sitepilot <support@sitepilot.io>"

# ----- Args ----- #

ARG PHP_VERSION="74"
ARG USER_ID=1000
ARG USER_GID=1000
ARG USER_NAME=sitepilot

ENV BUILD_USER_ID=$USER_ID
ENV BUILD_USER_GID=$USER_GID
ENV BUILD_USER_NAME=$USER_NAME
ENV BUILD_PHP_VERSION=$PHP_VERSION

ENV MAIL_RELAY_PORT="587"
ENV MAIL_RELAY_HOST="smtp.eu.mailgun.org"
ENV MAIL_RELAY_USER="postmaster@example.com"
ENV MAIL_RELAY_PASS="supersecret"

# ----- Common ----- #

RUN install_packages sudo less wget ca-certificates msmtp

# ----- Openlitespeed & PHP ----- #

RUN wget -O - http://rpms.litespeedtech.com/debian/enable_lst_debain_repo.sh | bash

RUN install_packages \
    lsphp$PHP_VERSION \
    lsphp$PHP_VERSION-mysql \
    lsphp$PHP_VERSION-imap \
    lsphp$PHP_VERSION-curl \
    lsphp$PHP_VERSION-common \
    lsphp$PHP_VERSION-json \
    lsphp$PHP_VERSION-redis \
    lsphp$PHP_VERSION-opcache \
    lsphp$PHP_VERSION-igbinary \
    lsphp$PHP_VERSION-ioncube \
    lsphp$PHP_VERSION-imagick \
    ols-modsecurity \
    openlitespeed

RUN ln -s /usr/local/lsws/lsphp$PHP_VERSION/bin/php /usr/local/bin/php

# ----- User ----- #

RUN addgroup --gid "$USER_GID" "$USER_NAME" \
    && adduser \
    --disabled-password \
    --gecos "" \
    --home "/opt/sitepilot/app" \
    --ingroup "$USER_NAME" \
    --no-create-home \
    --uid "$USER_ID" \
    "$USER_NAME" \
    && echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ----- Filesystem ----- #

COPY tags /

RUN chown root:root /opt/sitepilot

RUN chown -R $USER_NAME:$USER_NAME /opt/sitepilot/app

# ----- Config ----- #

USER $USER_ID

WORKDIR /opt/sitepilot/app

EXPOSE 80 443

ENTRYPOINT ["sudo", "--preserve-env", "/opt/sitepilot/scripts/entrypoint.sh"]

CMD ["/usr/local/lsws/bin/openlitespeed", "-d"]

# ----- Checks ----- #

RUN php -v \
    && msmtp --version
