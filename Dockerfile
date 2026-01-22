FROM php:5.6-apache


RUN docker-php-ext-install mysql mysqli

COPY src/ /var/www/html

WORKDIR /var/www/html

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 777 /var/www/html