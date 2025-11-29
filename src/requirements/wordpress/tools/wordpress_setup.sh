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
        --allow-root || echo "User already exists"

    chown -R www-data:www-data /var/www/html

    #wp post delete 1 --force --allow-root
    #wp post delete 2 --force --allow-root

    wp theme install twentytwentyfour --activate --allow-root || true #check this || true

	# ===============================
    # Delete Sample Page (clean setup)
    # ===============================
    echo "[INFO] Removing default Sample Page..."
    SAMPLE_ID=$(wp post list --post_type=page --title='Sample Page' --field=ID --allow-root)
    if [ "$SAMPLE_ID" != "" ]; then
        wp post delete $SAMPLE_ID --force --allow-root
    fi

	# ===============================
    # Create Homepage
    # ===============================
	echo "[INFO] Creating Home page..."
    HOME_ID=$(wp post create \
        --post_type=page \
        --post_title='Home' \
        --post_content='Welcome to my Inception WordPress website!' \
        --post_status=publish \
        --porcelain \
        --allow-root)
	
    # --- Set "Home" as the front page ---
    wp option update show_on_front 'page' --allow-root
    wp option update page_on_front $HOME_ID --allow-root
	
	# Enable comments on homepage
    wp post update $HOME_ID --comment_status=open --allow-root
	
	# ===============================
    # Create Second Page
    # ===============================
    echo "[INFO] Creating second page..."
    SECOND_ID=$(wp post create \
        --post_type=page \
        --post_title='Let us talk about the Kākāpō' \
        --post_content='This page explains something about this bird from New Zealand' \
        --post_status=publish \
        --porcelain \
        --allow-root)

	# ===============================
    # Create Menu + Login link
    # ===============================
    echo "[INFO] Creating navigation menu..."
    MENU_EXISTS=$(wp menu list --fields=term_id --format=ids --allow-root)

    if [ "$MENU_EXISTS" = "" ]; then
        MENU_ID=$(wp menu create "Main Menu" --porcelain --allow-root)

        # Add Home page
        wp menu item add-post "Main Menu" $HOME_ID --allow-root

        # Add second page
        wp menu item add-post "Main Menu" $SECOND_ID --allow-root

        # Add login link
        wp menu item add-custom "Main Menu" "Login" "/wp-login.php" --allow-root

        # Assign menu to theme (primary location)
        wp menu location assign "Main Menu" primary --allow-root || true
    fi

    wp option update blog_public 0 --allow-root
    wp option update default_pingback_flag 0 --allow-root
    wp option update default_ping_status 0 --allow-root
fi

exec php-fpm7.4 -F # check if 7.4 of 8.2
