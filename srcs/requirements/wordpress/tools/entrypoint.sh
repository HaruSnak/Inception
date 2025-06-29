#!/bin/bash
set -e

# Create directories with enough space
mkdir -p /var/www/html/wordpress/.wp-cli-cache
mkdir -p /var/www/html/wordpress/tmp
export WP_CLI_CACHE_DIR="/var/www/html/wordpress/.wp-cli-cache"
export TMPDIR="/var/www/html/wordpress/tmp"

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
while ! mysqladmin ping -h"mariadb" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
    sleep 1
done

echo "MariaDB is ready!"

# Change to WordPress directory
cd /var/www/html/wordpress

# Download WordPress if not already present
if [ ! -f wp-config.php ]; then
    echo "Setting up WordPress..."
    
    # Clean any previous incomplete installation
    rm -rf * .[^.]*
    
    # Download WordPress using wget instead of WP-CLI
    echo "Downloading WordPress manually..."
    wget -O wordpress.tar.gz https://wordpress.org/latest.tar.gz
    tar xzf wordpress.tar.gz --strip-components=1
    rm wordpress.tar.gz
    
    # Create wp-config.php
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$MYSQL_HOST" \
        --allow-root
    
    # Install WordPress
    wp core install \
        --url="$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root
    
    # Create additional user
    wp user create \
        "$WP_USER" \
        "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=subscriber \
        --allow-root
    
    echo "WordPress setup completed!"
else
    echo "WordPress already installed, skipping setup..."
fi

# Set correct permissions
chown -R www-data:www-data /var/www/html/wordpress
chmod -R 755 /var/www/html/wordpress

# Create run directory for php-fpm
mkdir -p /run/php

# Execute the main command
exec "$@"
