FROM debian:bookworm

RUN apt update && apt install -y \
    lsb-release \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg

# Add repo for PHP 8.3
RUN curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /usr/share/keyrings/php.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" \
    > /etc/apt/sources.list.d/php.list

RUN apt update && apt install -y \
    php8.3-fpm \
    php8.3-mysql \
    php8.3-curl \
    php8.3-gd \
    php8.3-intl \
    php8.3-mbstring \
    php8.3-soap \
    php8.3-xml \
    php8.3-xmlrpc \
    php8.3-zip && apt autoremove -y && apt autoclean

# WordPress CLI (command line interface) installation
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# PHP-FPM configuration
COPY conf/www.conf /etc/php/8.3/fpm/pool.d/
RUN mkdir -p /run/php

COPY tools/wordpress_setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wordpress_setup.sh

#script must be from entrypoint
ENTRYPOINT ["/usr/local/bin/wordpress_setup.sh"]

# Start PHP-FPM
CMD ["/usr/sbin/php-fpm8.3", "-F"]