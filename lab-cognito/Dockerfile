FROM php:7.1-apache

RUN sed -i 's!/var/www/html!/var/www/public!g' /etc/apache2/sites-available/000-default.conf

COPY app/ /var/www/

WORKDIR /var/www

EXPOSE 80
