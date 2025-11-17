#!/bin/bash

# ===========================
# Simple WordPress Bootstrap
# ===========================

# --- Ensure host data directory exist ---
if [ ! -d "${HOME}/data/wordpress" ]; then
    mkdir -p ${HOME}/data/wordpress
	echo "created wordpress data directory" 
fi

# --- Check if WordPress is already installed ---
if [ ! -f "wp-config.php" ]; then
    wp core download --allow-root

    wp config create --allow-root \
        --dbname=${WORDPRESS_DATABASE_NAME} \
        --dbuser=${DATABASE_USER} \
        --dbpass=$(cat ${DATABASE_USER_PW_FILE}) \
        --dbhost=${WORDPRESS_DATABASE_HOST} \
        --extra-php <<PHP
define( 'WP_DEBUG', false );
define( 'WP_DEBUG_LOG', false );
define( 'WP_DEBUG_DISPLAY', false );
PHP

    wp core install --allow-root \
        --url=${DOMAIN_NAME} \
        --title=${WORDPRESS_SITE_TITLE} \
        --admin_user=${WORDPRESS_ADMIN} \
        --admin_password=$(cat ${WORDPRESS_ADMIN_PW_FILE}) \
        --admin_email=${WORDPRESS_ADMIN_EMAIL}

    sleep 5  # waits 5 seconds to ensure DB setup is ready

    wp user create ${WORDPRESS_USER} ${WORDPRESS_USER_EMAIL} \
        --role=subscriber \
        --user_pass=$(cat ${WORDPRESS_USER_PW_FILE}) \
        --allow-root || echo "Extra user already exists"

    chown -R www-data:www-data /var/www/html

    #wp post delete 1 --force --allow-root
    #wp post delete 2 --force --allow-root

    wp theme install twentytwentyfour --activate --allow-root

	# --- Create a blank "Home" page ---
    HOME_ID=$(wp post create --post_type=page --post_title='Home' --post_status=publish --porcelain --allow-root)

    # --- Set "Home" as the front page ---
    wp option update show_on_front 'page' --allow-root
    wp option update page_on_front $HOME_ID --allow-root

	# Update homepage (rename Sample Page)
    #HOMEPAGE_ID=$(wp post list --post_type=page --title='Sample Page' --field=ID --allow-root)
    #wp post update $HOMEPAGE_ID \
    #    --post_title='My Inception' \
    #    --post_content='My project page' \
    #    --allow-root

	# Set "My Inception" the front page

	#wp option update show_on_front 'page' --allow-root
	#wp option update page_on_front $HOMEPAGE_ID --allow-root

    # wp post create --post_type=post \
    #    --post_title='Kakapo' \
    #    --post_content='Let us talk about Kakapos!' \
    #    --post_status=publish --allow-root

    wp option update blog_public 0 --allow-root
    wp option update default_pingback_flag 0 --allow-root
    wp option update default_ping_status 0 --allow-root
fi

exec php-fpm7.4 -F
