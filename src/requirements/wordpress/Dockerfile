# Dockerfile to create the WordPress image

FROM debian:bullseye

RUN apt update && apt install -y \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    php7.4-gd \
    php7.4-intl \
    php7.4-mbstring \
    php7.4-soap \
    php7.4-xml \
    php7.4-xmlrpc \
    php7.4-zip \
    curl

# WordPress CLI installation
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# PHP-FPM configuration
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/
RUN mkdir -p /run/php

COPY tools/wordpress_setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wordpress_setup.sh

WORKDIR /var/www/html

# Start PHP-FPM
CMD ["/usr/local/bin/wordpress_setup.sh"]
