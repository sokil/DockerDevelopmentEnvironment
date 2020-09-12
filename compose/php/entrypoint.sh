#!/usr/bin/env bash

### Prepare directory
chown www-data:www-data /var/www
cd /var/www/${COMPOSE_PROJECT_NAME}

### Set variables
export PHP_VERSION=$(php -r 'echo phpversion();')
export PATH=$PATH:/tools

### install php extensions
if [[ -z $(dpkg -l | grep libssl-dev) ]];
then
    # add common library requirements
    apt-get update
    apt-get install --no-install-recommends -y \
        iproute2 \
        libssl-dev \
        libzip-dev

    # zip
    apt-get install --no-install-recommends -y zlib1g-dev libzip-dev
    docker-php-ext-install zip

    # gd/exif extensions
    apt-get install --no-install-recommends -y libpng-dev libjpeg-dev libjpeg62-turbo-dev libfreetype6-dev
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
    docker-php-ext-install gd exif
      
    # intl extension
    apt-get install --no-install-recommends -y libicu-dev g++
    docker-php-ext-configure intl
    docker-php-ext-install intl

    # common extensions
    docker-php-ext-install \
        json \
        pdo \
        pdo_mysql \
        pdo_pgsql \
        opcache
        
    # node
    # curl -sL https://deb.nodesource.com/setup_8.x | bash -
    # apt-get install -y nodejs
    # npm install

    # grunt
    # npm install -g grunt-cli
    # grunt

    # xdebug
    pecl channel-update pecl.php.net
    
    # See compatibility with PHP at https://xdebug.org/download.php
    if [[ ${PHP_VERSION:0:2} == "5." ]]; then
        # Last version of xdebug with support PHP < 7.0 is 2.5.5
        pecl install xdebug-2.5.5;
    elif [[ ${PHP_VERSION:0:3} == "7.3" ]]; then
        # PHP 7.3 supported from v.2.7
        pecl install xdebug-2.9.1;
    else
        pecl install xdebug;
    fi
    
    docker-php-ext-enable xdebug.so
    
    # install composer
    curl -sS https://getcomposer.org/installer | php -- \
        --install-dir=/usr/bin \
        --filename=composer.phar

    # initial composer update
    composer.phar install \
        --no-scripts \
        -v \
        --optimize-autoloader
fi

### Register host machine
export DOCKERHOST_IP="$(/sbin/ip route|awk '/default/ { print $3 }')";
echo "$DOCKERHOST_IP dockerhost" >> /etc/hosts

### start server
php-fpm
