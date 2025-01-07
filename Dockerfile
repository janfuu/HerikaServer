# Use an official PHP image with Apache
FROM php:8.2-apache

# Set environment variables for the user
ENV USER=dwemer
ENV UID=1000
ENV GID=1000

# Create the user and group
RUN groupadd -g $GID $USER && \
    useradd -u $UID -g $GID -m -s /bin/bash $USER

# Install necessary PHP extensions and FFmpeg
RUN apt-get update && apt-get install -y \
    libpq-dev \
    postgresql-client \
    ffmpeg \
    git \
    graphviz \
    curl \
    unzip \
    libpq-dev \
    libbz2-dev \
    libicu-dev \
    libgmp-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libwebp-dev \
    libzip-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libonig-dev \
    --no-install-recommends \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure GD extension
RUN docker-php-ext-configure gd \
    --with-jpeg \
    --with-freetype \
    --with-webp

# Install PHP extensions
RUN docker-php-ext-install -j$(nproc) \
    pdo_pgsql \
    pgsql \
    bz2 \
    intl \
    gmp \
    gd \
    zip \
    mbstring \
    xml \
    curl \
    && docker-php-ext-enable opcache

# Install Composer:
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Enable Apache rewrite module
RUN a2enmod rewrite

# Set the working directory
WORKDIR /var/www/html

# Create required directories
RUN mkdir -p /var/www/html/HerikaServer/{connector,tts,data} && mkdir /var/www/html/data/

# Initialize composer.json files
COPY connector/composer.json /var/www/html/HerikaServer/connector/
COPY tts/composer.* /var/www/html/HerikaServer/tts/

# Install dependencies
WORKDIR /var/www/html/HerikaServer/connector
RUN composer install --no-dev --optimize-autoloader

WORKDIR /var/www/html/HerikaServer/tts
RUN composer install --no-dev --optimize-autoloader

# Copy the PHP application files into the container
COPY . /var/www/html/HerikaServer/
COPY ./docker/index.html /var/www/html/
COPY ./docker/dwemer.sql /var/www/html/data/

# Obsolte: Install Composer dependencies for all composer.json files in /var/www/html/HerikaServer and its subfolders
# RUN find /var/www/html/HerikaServer -name "composer.json" -execdir composer install \;

# Copy the connection check script into the container
COPY ./docker/wait-for-it.sh /usr/local/bin/wait-for-it
RUN chmod +x /usr/local/bin/wait-for-it

# Change ownership of the files to dwemer:www-data
RUN chown -R $USER:www-data /var/www/html && \
    chmod -R 775 /var/www/html

# Expose port 80 for HTTP traffic
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]