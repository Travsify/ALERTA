FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libpq-dev \
    libzip-dev \
    libicu-dev \
    nginx

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd intl zip

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy existing application directory contents
COPY . /var/www

# Install dependencies and set permissions
RUN composer install --no-interaction --optimize-autoloader --no-dev \
    && chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Create a custom Nginx configuration template
RUN echo "server { \
    listen 80; \
    index index.php index.html; \
    root /var/www/public; \
    location / { \
    try_files \$uri \$uri/ /index.php?\$query_string; \
    } \
    location ~ \.php$ { \
    fastcgi_pass 127.0.0.1:9000; \
    fastcgi_index index.php; \
    fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name; \
    include fastcgi_params; \
    } \
    }" > /etc/nginx/sites-available/default.template

# Create startup script
RUN echo "#!/bin/sh\n\
    # Set dynamic port for Nginx\n\
    if [ ! -z \"\$PORT\" ]; then\n\
    sed -i \"s/listen 80;/listen \$PORT;/g\" /etc/nginx/sites-available/default.template\n\
    fi\n\
    mv /etc/nginx/sites-available/default.template /etc/nginx/sites-available/default\n\
    \n\
    # FORCE environment visibility in PHP-FPM\n\
    echo \"clear_env = no\" >> /usr/local/etc/php-fpm.d/www.conf\n\
    echo \"variables_order = \\\"EGPCS\\\"\" > /usr/local/etc/php/conf.d/env.ini\n\
    \n\
    # Generate a clean .env file from environment variables\n\
    # This is often more reliable than relying on auto-detection\n\
    env | grep -E '^(APP_|DB_|MAIL_|SESSION_|CACHE_|PAYSTACK_|FILAMENT_|LOG_)' > /var/www/.env\n\
    \n\
    # Ensure APP_DEBUG is true so we can see errors\n\
    echo \"APP_DEBUG=true\" >> /var/www/.env\n\
    \n\
    # Handle APP_KEY specifically\n\
    if [ -z \"\$APP_KEY\" ]; then\n\
    echo \"WARNING: APP_KEY not found in environment. Generating...\"\n\
    php artisan key:generate --no-interaction --force\n\
    fi\n\
    \n\
    # Ensure permissions are correct\n\
    chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache\n\
    chmod -R 775 /var/www/storage /var/www/bootstrap/cache\n\
    \n\
    # Diagnostic\n\
    echo \"Starting Alerta Backend...\"\n\
    \n\
    # Standard Laravel boot sequence\n\
    php artisan config:clear\n\
    php artisan route:clear\n\
    php artisan view:clear\n\
    php artisan migrate --force\n\
    \n\
    # Start Nginx and PHP-FPM\n\
    nginx\n\
    php-fpm" > /start.sh && chmod +x /start.sh

# Expose port (Render ignores this but good for local)
EXPOSE 80

# Run the startup script
CMD ["/start.sh"]
