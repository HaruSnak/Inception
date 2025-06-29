#!/bin/bash
set -e

# Replace domain name in nginx config if environment variable is set
if [ ! -z "$DOMAIN_NAME" ]; then
    sed -i "s/shmoreno.42.fr/$DOMAIN_NAME/g" /etc/nginx/nginx.conf
fi

# Create directories if they don't exist
mkdir -p /var/www/html/wordpress

# Execute the main command
exec "$@"
