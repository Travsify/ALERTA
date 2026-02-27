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
    # Create or update .env from current environment vars (very reliable for Laravel)\n\
    # We exclude sensitive internal vars and ones with spaces\n\
    printenv | grep -E '^(APP_|DB_|MAIL_|SESSION_|CACHE_|PAYSTACK_|FILAMENT_|LOG_)' > /var/www/.env\n\
    \n\
    # Sanitize and Check APP_KEY from environment\n\
    CLEAN_KEY=\$(echo \$APP_KEY | sed 's/\"//g' | sed \"s/'//g\")\n\
    if [ -z \"\$CLEAN_KEY\" ] || [ \${#CLEAN_KEY} -lt 16 ]; then\n\
    echo \"WARNING: APP_KEY missing or invalid. Generating temporary key...\"\n\
    CLEAN_KEY=\$(php artisan key:generate --show --no-interaction)\n\
    echo \"APP_KEY=\$CLEAN_KEY\" >> /var/www/.env\n\
    export APP_KEY=\$CLEAN_KEY\n\
    fi\n\
    \n\
    # Diagnostic\n\
    echo \"Booting Alerta... Key length: \${#APP_KEY} characters.\"\n\
    \n\
    # Standard Laravel boot sequence (no cache to be safe during debugging)\n\
    php artisan config:clear\n\
    php artisan route:clear\n\
    php artisan view:clear\n\
    php artisan migrate --force\n\
    \n\
    # Start Nginx and PHP-FPM\n\
    echo \"Starting Nginx and PHP-FPM...\"\n\
    nginx\n\
    php-fpm" > /start.sh && chmod +x /start.sh

# Expose port (Render ignores this but good for local)
EXPOSE 80

# Run the startup script
CMD ["/start.sh"]
