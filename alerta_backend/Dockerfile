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

# Delete any local .env file that might have been copied
RUN rm -f /var/www/.env

# Install dependencies and set permissions
RUN composer install --no-interaction --optimize-autoloader --no-dev \
    && chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Create Nginx configuration template
RUN echo 'server { \
    listen 80; \
    index index.php index.html; \
    root /var/www/public; \
    location / { \
    try_files $uri $uri/ /index.php?$query_string; \
    } \
    location ~ \.php$ { \
    fastcgi_pass 127.0.0.1:9000; \
    fastcgi_index index.php; \
    fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name; \
    include fastcgi_params; \
    } \
    }' > /etc/nginx/sites-available/default.template

# Make startup script executable
RUN chmod +x /var/www/start.sh

EXPOSE 80

CMD ["/var/www/start.sh"]
