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
    sed -i \"s/listen 80;/listen \${PORT:-80};/g\" /etc/nginx/sites-available/default.template\n\
    mv /etc/nginx/sites-available/default.template /etc/nginx/sites-available/default\n\
    \n\
    # FORCE environment inheritance in PHP-FPM\n\
    if [ -f /usr/local/etc/php-fpm.d/www.conf ]; then\n\
    echo \"clear_env = no\" >> /usr/local/etc/php-fpm.d/www.conf\n\
    fi\n\
    \n\
    # Sanitize and Check APP_KEY\n\
    export APP_KEY=\$(echo \$APP_KEY | sed 's/\"//g' | sed \"s/'//g\")\n\
    \n\
    if [ -z \"\$APP_KEY\" ] || [ \${#APP_KEY} -lt 16 ]; then\n\
    echo \"WARNING: APP_KEY missing or invalid. Generating temporary key...\"\n\
    export APP_KEY=\$(php artisan key:generate --show --no-interaction)\n\
    fi\n\
    \n\
    # Force debug mode to see exact issues\n\
    export APP_DEBUG=true\n\
    \n\
    # Standard Laravel boot sequence\n\
    php artisan config:clear\n\
    php artisan config:cache\n\
    php artisan route:cache\n\
    php artisan view:cache\n\
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
