# Use the official PHP 8.2 FPM image as the base
FROM php:8.2-fpm

# Set working directory inside the container
WORKDIR /var/www/html

# Use the official PHP 8.2 FPM image as the base
FROM php:8.2-fpm

# Set working directory inside the container
WORKDIR /var/www/html

# Update packages and install required system tools and PHP extensions
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    gettext-base \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Copy Composer from official Composer image to manage PHP dependencies
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy the application source code into the container
COPY . .

# Configure Git safe directory and install PHP dependencies for production
RUN git config --global --add safe.directory /var/www/html \
    && composer install --no-dev --optimize-autoloader

# Ensure public assets directory exists and has proper permissions
RUN mkdir -p public/storage public/js public/css public/images public/frontend public/backend \
    && chmod -R 755 public

# Set appropriate permissions for Laravel storage and cache directories
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/public \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 755 /var/www/html/public

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Run PHP-FPM
CMD ["php-fpm"]
