#!/bin/bash
set -e

# If PORT is not set, default to 80
PORT=${PORT:-80}

# Replace the PORT in apache config
sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/<VirtualHost \*:80>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf

# Remove any .env file so Laravel uses Render's environment variables only
rm -f /var/www/html/.env

# Run Laravel optimizations
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Run migrations
php artisan migrate --force

# Start Apache in foreground
exec apache2-foreground
