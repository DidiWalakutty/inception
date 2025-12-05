#!/bin/bash
set -e

mkdir -p /run/php
chown -R www-data:www-data /run/php

if [ ! -e "/var/www/html/$DOMAIN_NAME/.wordpress_setup_done" ]; then
    mkdir -p "/var/www/html/$DOMAIN_NAME"
    chown -R www-data:www-data "/var/www/html/$DOMAIN_NAME"
    chmod -R 755 "/var/www/html/$DOMAIN_NAME"
    cd "/var/www/html/$DOMAIN_NAME"

    # Install WP-CLI if not installed
    if [ ! -f /usr/local/bin/wp ]; then
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        mv wp-cli.phar /usr/local/bin/wp
        chmod +x /usr/local/bin/wp
    fi

    echo "Waiting for database..."
    until nc -z "$WORDPRESS_DATABASE_HOST" 3306; do
        echo 'Waiting for DB...' >> output
        sleep 5
    done

    # Download and configure WordPress
    if [ ! -f wp-config.php ]; then
        echo "Downloading WordPress..."
        wp core download --allow-root

        echo "Creating wp-config.php..."
        wp config create \
            --dbname="$WORDPRESS_DATABASE_NAME" \
            --dbuser="$DATABASE_USER" \
            --dbpass="$(cat "$DATABASE_USER_PW_FILE")" \
            --dbhost="$WORDPRESS_DATABASE_HOST:3306" \
            --allow-root

        echo "Installing WordPress..."
        wp core install \
            --url="$DOMAIN_NAME/" \
            --title="Inception" \
            --admin_user="$WORDPRESS_ADMIN" \
            --admin_password="$(cat "$WORDPRESS_ADMIN_PW_FILE")" \
            --admin_email="$WORDPRESS_ADMIN_EMAIL" \
            --allow-root

		# Install Twenty Twenty-One theme
		wp theme install twentytwentyone --activate --allow-root

        echo "Creating additional user..."
        wp user create "$WORDPRESS_USER" "$WORDPRESS_USER_EMAIL" \
            --role=author \
            --user_pass="$(cat "$WORDPRESS_USER_PW_FILE")" \
            --allow-root

        # Delete default post
        DEFAULT_POST_ID=$(wp post list --post_type=post --field=ID --allow-root | head -n 1 || true)
        if [ -n "$DEFAULT_POST_ID" ]; then
            wp post delete "$DEFAULT_POST_ID" --force --allow-root
        fi

        # Create homepage page with comments enabled
        HOMEPAGE_ID=$(wp post create \
            --post_title="About Inception" \
            --post_content="This is Didi's inception!" \
            --post_status=publish \
            --post_type=page \
            --comment_status=open \
            --porcelain \
            --allow-root)

        # Set the page as the front page
        wp option update show_on_front page --allow-root
        wp option update page_on_front "$HOMEPAGE_ID" --allow-root

    fi

    # Mark setup as done
    touch "/var/www/html/$DOMAIN_NAME/.wordpress_setup_done"
else
    echo "WordPress already exists. Skipping setup."
fi

# Start PHP-FPM
exec "$@"
