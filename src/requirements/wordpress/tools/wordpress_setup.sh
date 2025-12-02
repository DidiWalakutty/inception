#!/bin/bash
set -e

mkdir -p /run/php
chown -R www-data:www-data /run/php

if [ ! -e /var/www/html/$DOMAIN_NAME/.wordpress_setup_done ]; then	
	mkdir -p /var/www/html/$DOMAIN_NAME
	chown -R www-data:www-data /var/www/html/$DOMAIN_NAME
	chmod -R 755 /var/www/html/$DOMAIN_NAME
	cd /var/www/html/$DOMAIN_NAME

	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
	chmod +x /usr/local/bin/wp


	sleep 10
	until nc -z $WORDPRESS_DATABASE_HOST 3306; do echo 'Waiting db...' >>output && sleep 5; done
    
	
	if [ ! -f /var/www/html/$DOMAIN_NAME/wp-config.php ]; then
    	echo "Downloading WordPress..."
    	wp core download --allow-root

    	echo "Creating wp-config.php..."
    	wp config create \
			--path=/var/www/html/$DOMAIN_NAME \
            --dbname="$WORDPRESS_DATABASE_NAME" \
            --dbuser="$DATABASE_USER" \
            --dbpass="$(cat "${DATABASE_USER_PW_FILE}")" \
            --dbhost="$WORDPRESS_DATABASE_HOST:3306" \
            --allow-root

    	echo "Installing WordPress..."
    	wp core install \
			--path=/var/www/html/$DOMAIN_NAME \
            --url="$DOMAIN_NAME/" \
            --title="Inception" \
            --admin_user="$WORDPRESS_ADMIN" \
            --admin_password="$(cat "${WORDPRESS_ADMIN_PW_FILE}")" \
            --admin_email="$WORDPRESS_ADMIN_EMAIL" \
            --allow-root

    	echo "Creating additional user..."
    	wp user create "$WORDPRESS_USER" "$WORDPRESS_USER_EMAIL" \
			--path=/var/www/html/$DOMAIN_NAME \
    	    --path=/var/www/html/$DOMAIN_NAME \
            --role=author \
            --user_pass="$(cat "${WORDPRESS_USER_PW_FILE}")" \
            --allow-root
		
		# until nc -z redis 6379; do echo 'Waiting for Redis...' && sleep 5; done

		# echo "Installing & Activating Redis Cache Plugin..."
        # wp plugin install redis-cache --activate --allow-root
		
        # echo "Setting Redis Cache Config in wp-config.php..."
        # wp config set WP_REDIS_HOST "redis" --allow-root
        # wp config set WP_REDIS_PORT "6379" --raw --allow-root
        # wp config set WP_CACHE true --raw --allow-root
		# wp config set WP_CACHE true --raw --allow-root --path=/var/www/html/$DOMAIN_NAME

        # echo "Enabling Redis Cache..."
        # wp redis enable --allow-root --path=/var/www/html/$DOMAIN_NAME
    fi

    touch /var/www/html/$DOMAIN_NAME/.wordpress_setup_done
else
    echo "WordPress already exists. Skipping download."
fi


# Start PHP-FPM
exec "$@"