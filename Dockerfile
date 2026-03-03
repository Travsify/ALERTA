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

# Install dependencies
# We use --no-scripts to avoid database connection attempts during build (e.g. filament:upgrade)
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts \
    && chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Ensure Nginx logs go to stdout/stderr
RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

# Ensure Nginx directories exist and are clean
RUN mkdir -p /etc/nginx/sites-enabled && rm -f /etc/nginx/sites-enabled/*

# Create Nginx configuration template for the public folder
RUN echo 'server { \
    listen 80 default_server; \
    server_name _; \
    index index.php index.html; \
    root /var/www/html/public; \
    location /test-debug { \
    return 200 "NGINX_IS_ALIVE_ROOT_IS_PUBLIC_PORT_$PORT"; \
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

# Copy the resilient start script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
# Fix Windows line endings
RUN sed -i 's/\r$//' /usr/local/bin/docker-entrypoint.sh

# Triggering fresh build trace: bc80d0b_52432f5_trigger
EXPOSE 80

CMD ["/usr/local/bin/docker-entrypoint.sh"]
