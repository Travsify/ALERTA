#!/bin/sh
set -e

echo "=== Alerta Backend Startup (Resilient) ==="

# 1. Set dynamic port for Nginx
if [ ! -z "$PORT" ]; then
    sed -i "s/listen 80;/listen $PORT;/g" /etc/nginx/sites-available/default.template
fi
mv /etc/nginx/sites-available/default.template /etc/nginx/sites-available/default

# 2. Force PHP-FPM to inherit environment variables
cat > /usr/local/etc/php-fpm.d/env.conf <<EOF
[www]
clear_env = no
EOF
echo 'variables_order = "EGPCS"' > /usr/local/etc/php/conf.d/env.ini

# 3. Build .env file from environment variables
# This ensures Laravel always has access to the correct configuration at runtime
env | grep -E '^(APP_|DB_|MAIL_|SESSION_|CACHE_|PAYSTACK_|FILAMENT_|LOG_|REDIS_|QUEUE_|SENTRY_|FIREBASE_|TELEGRAM_)' > /var/www/html/.env 2>/dev/null || true

# 4. Handle APP_KEY - generate if missing or invalid
KEY_LEN=${#APP_KEY}
echo "Current APP_KEY length: $KEY_LEN"

if [ "$KEY_LEN" -lt 40 ] 2>/dev/null; then
    echo "WARNING: APP_KEY is missing or too short ($KEY_LEN chars). Generating a new one..."
    NEW_KEY=$(php -r "echo 'base64:' . base64_encode(random_bytes(32));")
    export APP_KEY="$NEW_KEY"
    # Remove any existing APP_KEY line and add the new one
    grep -v "^APP_KEY=" /var/www/html/.env > /var/www/html/.env.tmp 2>/dev/null || true
    mv /var/www/html/.env.tmp /var/www/html/.env 2>/dev/null || true
    echo "APP_KEY=$NEW_KEY" >> /var/www/html/.env
    echo "Generated new APP_KEY: ${NEW_KEY:0:15}... (length: ${#NEW_KEY})"
fi

# 5. Fix permissions so PHP-FPM (www-data) can read everything
chown www-data:www-data /var/www/html/.env
chmod 644 /var/www/html/.env
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# 6. Laravel boot sequence (no caching to avoid stale config)
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan migrate --force || echo "Migration failed but continuing..."

echo "=== Starting Nginx + PHP-FPM ==="
nginx
php-fpm
