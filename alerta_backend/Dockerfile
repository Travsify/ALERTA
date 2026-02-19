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

# Copy existing application directory permissions
COPY --chown=www-data:www-data . /var/www

# Create a custom Nginx configuration
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
    }" > /etc/nginx/sites-available/default

# Create startup script
RUN echo "#!/bin/sh\n\
    php artisan config:cache\n\
    php artisan route:cache\n\
    php artisan view:cache\n\
    php artisan migrate --force\n\
    nginx\n\
    php-fpm" > /start.sh && chmod +x /start.sh

# Expose port 80
EXPOSE 80

# Run the startup script
CMD ["/start.sh"]
