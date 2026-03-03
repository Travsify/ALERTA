# Use PHP 8.2 with FPM
FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libicu-dev \
    libzip-dev \
    zip \
    unzip \
    libpq-dev \
    nginx \
    && docker-php-ext-install pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd intl zip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy project files from the alerta_backend directory
COPY alerta_backend/ .

# Install dependencies (temporarily allowing dev for debugging)
RUN composer install --no-interaction --optimize-autoloader \
    && chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Create Nginx configuration template for the public folder
RUN echo 'server { \
    listen 80; \
    index index.php index.html; \
    root /var/www/html/public; \
    location /test-debug { \
    return 200 "NGINX_IS_ALIVE_ROOT_IS_PUBLIC"; \
    } \
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

# Copy the resilient start script (using the one from alerta_backend to root context if needed, but we'll use a modified root one)
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Fix Windows line endings if necessary
RUN sed -i 's/\r$//' /usr/local/bin/docker-entrypoint.sh

# Triggering fresh build trace: bc80d0b_52432f5_trigger
EXPOSE 80

CMD ["/usr/local/bin/docker-entrypoint.sh"]
