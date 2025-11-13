#!/bin/bash

# ===========================
# Simple WordPress Bootstrap
# ===========================

# --- Ensure host data directory exist ---
if [ ! -d "${HOME}/data/wordpress" ]; then
	mkdir -p ${HOME}/data/wordpress
fi

# --- Check if WordPress is already installed ---
if [ ! -f "wp-config.php" ]; then
	wp core download --allow-root

	wp config create --allow-root \					# Creates the wp-config.php using our .env environment variables
        --dbname=${WORDPRESS_DATABASE_NAME} \
        --dbuser=${DATABASE_USER} \
        --dbpass=$(cat ${DATABASE_USER_PW_FILE}) \
        --dbhost=${WORDPRESS_DATABASE_HOST} \
        --extra-php <<PHP							# makes adding custom lines possible
define( 'WP_DEBUG', false );
define( 'WP_DEBUG_LOG', false );
define( 'WP_DEBUG_DISPLAY', false );
PHP

	wp core install --allow-root \					# installs WordPress, connects to mariadb, creates Admin User, sets title + URL
        --url=${DOMAIN_NAME} \
        --title=${WORDPRESS_SITE_TITLE} \
        --admin_user=${WORDPRESS_ADMIN} \
        --admin_password=$(cat ${WORDPRESS_ADMIN_PW_FILE}) \
        --admin_email=${WORDPRESS_ADMIN_EMAIL}

	sleep 5											# waits 5 seconds to ensure DB setup is ready
    
	wp user create ${WORDPRESS_USER} ${WORDPRESS_USER_EMAIL} \
		--role=subscriber \
		--user_pass=$(cat ${WORDPRESS_USER_PW_FILE}) \
		--allow-root || echo "Extra user already exists"

	chown -R www-data:www-data /var/www/html		# gives ownership of the WP files to the www-data user (NGINX uses this)

	#wp post delete 1 --force --allow-root			# removes default "Hello World" + "Sample Page"
    #wp post delete 2 --force --allow-root

	# do we need to reset/add/delete sidebars?
	#wp widget reset sidebar-1 --allow-root
	#wp widget add categories sidebar-1 --allow-root
	#wp widget add recent-posts sidebar-1 --allow-root

	wp theme install twentytwentyfive --activate --allow-root

	# --- Update the existing homepage ---
	HOMEPAGE_ID=$(wp post list --post_type=page --title='Homepage' --field=ID --allow-root)
	wp post update $HOMEPAGE_ID \
		--post_title='My Inception' \
		--post_content='My project page' \
		--allow-root

	# --- Add a new post ---
    wp post create --post_type=post \
        --post_title='Kakapo' \
        --post_content='Let us talk about Kakapos!' \
        --post_status=publish --allow-root

	# --- Privacy settings ---
	wp option update blog_public 0 --allow-root				# Makes sure the site isn't visible to search engines
	wp option update default_pingback_flag 0 --allow-root	# Disable pingbacks for privacy
	wp option update default_ping_status 0 --allow-root
fi

exec php-fpm7.4 -F