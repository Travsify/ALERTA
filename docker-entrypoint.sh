#!/bin/sh
set -e
set -x

echo "=== Alerta Backend Startup (Resilient Debug) ==="

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
# Critical: Include DATABASE_URL and other Render-specific vars
env | grep -E '^(APP_|DB_|DATABASE_|MAIL_|SESSION_|CACHE_|PAYSTACK_|FILAMENT_|LOG_|REDIS_|QUEUE_|SENTRY_|FIREBASE_|TELEGRAM_)' | grep -v '^APP_DEBUG=' > /var/www/html/.env 2>/dev/null || true

# 4. Mandatory Environment Overrides for Debugging & Render
echo "APP_DEBUG=true" >> /var/www/html/.env
echo "LOG_CHANNEL=stderr" >> /var/www/html/.env
export APP_DEBUG=true
export LOG_CHANNEL=stderr

# 5. Diagnostic: Check if we can see the vars
echo "Checking Captured Variables..."
grep -E '^(DB_|DATABASE_|APP_DEBUG)' /var/www/html/.env | cut -d= -f1

# 6. Handle APP_KEY - MUST start with "base64:" for Laravel
# Render's generateValue produces a random string WITHOUT the base64: prefix,
# which causes Laravel's encrypter to fail silently with a 500 error.
echo "Current APP_KEY value starts with: ${APP_KEY:0:7}"

NEEDS_NEW_KEY=false
if [ -z "$APP_KEY" ]; then
    echo "WARNING: APP_KEY is empty."
    NEEDS_NEW_KEY=true
elif echo "$APP_KEY" | grep -qv "^base64:"; then
    echo "WARNING: APP_KEY does not start with 'base64:' — invalid for Laravel."
    NEEDS_NEW_KEY=true
fi

if [ "$NEEDS_NEW_KEY" = "true" ]; then
    echo "Generating a proper Laravel APP_KEY..."
    NEW_KEY=$(php -r "echo 'base64:' . base64_encode(random_bytes(32));")
    export APP_KEY="$NEW_KEY"
    # Remove any existing APP_KEY line and add the new one
    grep -v "^APP_KEY=" /var/www/html/.env > /var/www/html/.env.tmp 2>/dev/null || true
    mv /var/www/html/.env.tmp /var/www/html/.env 2>/dev/null || true
    echo "APP_KEY=$NEW_KEY" >> /var/www/html/.env
    echo "Generated new APP_KEY: ${NEW_KEY:0:15}... (length: ${#NEW_KEY})"
fi

# 6. Fix permissions so PHP-FPM (www-data) can read everything
chown www-data:www-data /var/www/html/.env
chmod 644 /var/www/html/.env
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# 7. Laravel boot sequence (no caching to avoid stale config)
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan filament:upgrade --ansi
php artisan migrate --force || echo "Migration failed but continuing..."

echo "=== Starting Nginx + PHP-FPM ==="
nginx
php-fpm
