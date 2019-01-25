FROM php:7.2-fpm-alpine

ENV PHALCON_VERSION 3.4.2
ENV XDEBUG_VERSION 2.6.1
ENV XDEBUG_PORT 9000

# Installing Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Pre run
RUN docker-php-source extract \
    && apk add --update --virtual .build-deps autoconf g++ make pcre-dev icu-dev openssl-dev \

# Install GIT
    && apk add git openssh \

# Install mysql goodness
    && docker-php-ext-install mysqli pdo_mysql \


# Installing CakePHP deps
    && apk add icu-libs icu \
    && docker-php-ext-install intl \

# Installing Phalcon deps
    && cd /usr/local/etc/php/ \
    && curl -LO https://github.com/phalcon/cphalcon/archive/v4.0.0-alpha1.tar.gz \
    && tar xzf v4.0.0-alpha1.tar.gz \
    && cd cphalcon-4.0.0-alpha1/build \
    && sh install \
    && echo "extension=phalcon.so" > /usr/local/etc/php/conf.d/phalcon.ini \

# Installing XDebug
    && cd /usr/local/etc/php/ \
    && curl -LO http://xdebug.org/files/xdebug-$XDEBUG_VERSION.tgz \
    && tar -zxvf xdebug-$XDEBUG_VERSION.tgz \
    && cd xdebug-$XDEBUG_VERSION && phpize \
    && ./configure --enable-xdebug && make && make install \
    && echo "zend_extension=xdebug.so" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_handler=dbgp" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_port=${XDEBUG_PORT}" >> /usr/local/etc/php/conf.d/xdebug.ini \

# Post run
    && docker-php-source delete \
    && apk del --purge .build-deps \
    && rm -rf /tmp/pear \
    && rm -rf /var/cache/apk/* \
    && rm -rf /usr/local/etc/php/cphalcon-4.0.0-alpha1 \
    && rm /usr/local/etc/php/v4.0.0-alpha1.tar.gz

# Expose new ports
EXPOSE ${XDEBUG_PORT}
