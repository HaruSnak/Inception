#!/bin/bash

# Script to configure domain name in /etc/hosts
DOMAIN="shmoreno.42.fr"
IP="127.0.0.1"

# Check if entry already exists
if grep -q "$DOMAIN" /etc/hosts; then
    echo "Domain $DOMAIN already exists in /etc/hosts"
else
    echo "Adding $DOMAIN to /etc/hosts"
    echo "$IP $DOMAIN" | sudo tee -a /etc/hosts
fi

echo "Domain configuration completed. You can now access your site at https://$DOMAIN"
