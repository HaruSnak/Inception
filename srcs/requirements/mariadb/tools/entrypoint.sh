#!/bin/bash
set -e

# Initialize database if not exists
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "Initializing MariaDB database..."
    
    # Check if mysql system database exists, if not initialize
    if [ ! -d "/var/lib/mysql/mysql" ]; then
        mysql_install_db --user=mysql --datadir=/var/lib/mysql
    fi
    
    # Start MariaDB temporarily
    mysqld_safe --datadir=/var/lib/mysql &
    pid="$!"
    
    # Wait for MariaDB to start
    echo "Waiting for MariaDB to start..."
    while ! mysqladmin ping --silent; do
        sleep 1
    done
    
    echo "MariaDB started. Setting up database and users..."
    
    # Secure MariaDB installation and create database/user
    mysql <<EOF
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}');
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';

-- Allow root connections from any host
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;
EOF
    
    echo "Database setup completed!"
    
    # Stop temporary MariaDB instance
    kill "$pid"
    wait "$pid"
fi

# Set correct permissions
chown -R mysql:mysql /var/lib/mysql
chmod 755 /var/lib/mysql

# Execute the main command
exec "$@"
