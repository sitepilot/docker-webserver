FROM bitnami/minideb:buster
LABEL maintainer "Sitepilot <support@sitepilot.io>"

# ----- Args ----- #

ARG PHP_VERSION="74"

ARG USER_ID=1000
ARG USER_GID=1000
ARG USER_NAME=sitepilot

ENV USER_ID=$USER_ID
ENV USER_GID=$USER_GID
ENV USER_NAME=$USER_NAME

ENV PHP_VERSION=$PHP_VERSION

ENV MAIL_RELAY_PORT="587"
ENV MAIL_RELAY_HOST="smtp.eu.mailgun.org"
ENV MAIL_RELAY_USER="postmaster@example.com"
ENV MAIL_RELAY_PASS="supersecret"

# ----- Common ----- #

RUN install_packages sudo less rsync ca-certificates curl wget nano msmtp

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

# ----- WPCLI ----- #

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# ----- Composer ----- #

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && mv composer.phar /usr/local/bin/composer \
    && php -r "unlink('composer-setup.php');"

# ----- User ----- #

RUN addgroup --gid "$USER_GID" "$USER_NAME" \
    && adduser \
    --disabled-password \
    --gecos "" \
    --home "/opt/sitepilot" \
    --ingroup "$USER_NAME" \
    --no-create-home \
    --uid "$USER_ID" \
    "$USER_NAME" \
    && usermod -aG sudo $USER_NAME \
    && echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ----- Filesystem ----- #

COPY tags /

RUN chown -R sitepilot:sitepilot /opt/sitepilot/site

# ----- Config ----- #

USER $USER_NAME

WORKDIR /opt/sitepilot/site/public

EXPOSE 80 443 7080

ENTRYPOINT ["sudo", "--preserve-env", "/opt/sitepilot/scripts/entrypoint.sh"]

CMD ["sudo", "/usr/local/lsws/bin/openlitespeed", "-d"]

# ----- Checks ----- #

RUN php -v \
    && wp --version \
    && composer --version \
    && msmtp --version
