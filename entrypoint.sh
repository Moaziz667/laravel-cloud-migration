#!/bin/sh
set -e

# Create the real .env from the template
envsubst < /var/www/html/.env.template > /var/www/html/.env

# Fix permissions for Laravel
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Start PHP
exec php-fpm
