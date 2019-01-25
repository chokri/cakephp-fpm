FROM php:7.2.14-fpm-stretch

# Install selected extensions and other stuff
RUN apt-get update \
    && apt-get -y --no-install-recommends install  php7.2-mysql php7.2-intl php7.2-mbstring php7.2-sqlite3\
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Enable and configure Intl
RUN docker-php-ext-configure intl \
    && docker-php-ext-install intl
