#!/usr/bin/env bash

### Prepare directory
chown www-data:www-data /var/www
cd /var/www/${COMPOSE_PROJECT_NAME}

### Register host machine
export DOCKERHOST_IP="$(/sbin/ip route|awk '/default/ { print $3 }')";
echo "$DOCKERHOST_IP dockerhost" >> /etc/hosts

### Set variables
export PATH=$PATH:/tools

### install php extensions
if [[ -z $(dpkg -l | grep libssl-dev) ]];
then
    # add library requirements
    apt-get update
    apt-get install --no-install-recommends -y \
        libssl-dev

    # install ext-zip
    docker-php-ext-install \
        zip \
        json \
        pdo \
        pdo_mysql \
        opcache

    # node
    # curl -sL https://deb.nodesource.com/setup_6.x | bash -
    # apt-get install -y nodejs

    # grunt
    # npm install -g grunt-cli

    # xdebug
    pecl install xdebug
    docker-php-ext-enable xdebug.so
fi


### install composer
if [[ -z $(which composer.phar) ]];
then
    # install composer
    curl -sS https://getcomposer.org/installer | php -- \
        --install-dir=/usr/bin \
        --filename=composer.phar

    # update composer
    composer.phar install \
        --no-scripts \
        -v \
        --optimize-autoloader
fi

### start server
php-fpm
