#!/bin/bash

# =========================== #
# Simple MariaDB Bootstrap    #
# =========================== #

MYSQL_DB="${WORDPRESS_DATABASE_NAME}"
MYSQL_USER="${DATABASE_USER}"                       	# Username for the WordPress database
MYSQL_PASSWORD="$(cat ${DATABASE_USER_PW_FILE})"   		# User password
MYSQL_ROOT_PASSWORD="$(cat ${DATABASE_ROOT_PW_FILE})"	# Root password
DATA_DIR="/var/lib/mysql"                           	# Default MariaDB data directory

# --- Ensure persistent data directory exists --- 
if [ ! -d "${HOME}/data/mariadb" ]; then
	mkdir -p ${HOME}/data/mariadb
	echo "created mariadb data directory"
fi

# --- Initialize database if WordPress DB is missing ---
if [ ! -d "${DATA_DIR}/${MYSQL_DB}" ]; then					# Check if MariaDB system DB exists, skip setup if it does
    echo "[INFO] Initializing MariaDB data directory..."
    
    mysql_install_db --user=mysql --datadir="${DATA_DIR}"	# Create system databases files (tables, metadata, etc)

    echo "[INFO] Starting MariaDB temporarily..."
    mysqld_safe --datadir="${DATA_DIR}" &					# Start MariaDB in the background temporarily (creates main database, users etc)

    echo "[INFO] Waiting for MariaDB to start..."
    until mysqladmin ping >/dev/null 2>&1; do				# Waits until the server is ready
        sleep 1
    done

    echo "[INFO] Creating WordPress database and user..."
    mysql -u root <<EOF																# Runs SQL commands directly inside MariaDB
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DB}\`;										# Create WordPress DB
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';	# Create WP DB user
GRANT ALL PRIVILEGES ON \`${MYSQL_DB}\`.* TO '${MYSQL_USER}'@'%';					# Give user full privileges on WP DB
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';				# Set root password
FLUSH PRIVILEGES;																	# Apply changes
EOF

    echo "[INFO] Shutting down temporary MariaDB..."
    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown							# Stops temporary MariaDB safely after setup
fi

# --- Start MariaDB normally ---
echo "[INFO] Starting MariaDB in normal mode..."
exec mysqld_safe --datadir="${DATA_DIR}"					# Start MariaDB in normal mode; keeps container running
