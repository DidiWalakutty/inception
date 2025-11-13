#!/bin/bash
# ^ ensures your script runs with the Bash shell
# ===========================
# Simple MariaDB Bootstrap
# ===========================

# --- Load variables from .env and Docker secrets ---
MYSQL_DB="${WORDPRESS_DATABASE_NAME}"					# WordPress database name
MYSQL_USER="${DATABASE_USER}"                       	# MariaDB user for WordPress
MYSQL_PASSWORD="$(cat ${DATABASE_USER_PW_FILE})"   		# Password for WordPress user (from secret)
MYSQL_ROOT_PASSWORD="$(cat ${DATABASE_ROOT_PW_FILE})"	# Root password (from secret)
DATA_DIR="/var/lib/mysql"                           	# Default MariaDB data directory

# --- Ensure host data directory exists --- 
if [ ! -d "${HOME}/data/mariadb" ]; then				# Check if data directory exists
	mkdir -p ${HOME}/data/mariadb
fi														# every if-statement must be closed with a matching 'fi' == end block

# --- Initialize database if it's empty ---
if [ ! -d "${DATA_DIR}/mysql" ]; then						# Check if MariaDB system DB exists
    echo "[INFO] Initializing MariaDB data directory..."
    
    # Create the system databases and metadata
    mysql_install_db --user=mysql --datadir="${DATA_DIR}"	# Create initial DB files (system tables, metadata)

    echo "[INFO] Starting MariaDB temporarily..."
    mysqld_safe --datadir="${DATA_DIR}" &					# Start MariaDB in the background temporarily

    echo "[INFO] Waiting for MariaDB to start..."
    until mysqladmin ping >/dev/null 2>&1; do				# Wait until the server is ready
        sleep 1
    done

    echo "[INFO] Creating WordPress database and user..."
    mysql -u root <<EOF																# Connect to MariaDB as root
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DB}\`;										# Create WP database if it doesn't exist
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';	# Create DB user
GRANT ALL PRIVILEGES ON \`${MYSQL_DB}\`.* TO '${MYSQL_USER}'@'%';					# Give user full privileges on WP DB
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';				# Set root password
FLUSH PRIVILEGES;																	# Apply changes
EOF

    echo "[INFO] Shutting down temporary MariaDB..."
    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown							# Stop temporary MariaDB safely
fi

# --- Start MariaDB normally ---
echo "[INFO] Starting MariaDB in normal mode..."
exec mysqld_safe --datadir="${DATA_DIR}"			# Start MariaDB in normal mode; keeps container running
