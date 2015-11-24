# from https://www.drupal.org/requirements/php#drupalversions
FROM php:5.6-apache

MAINTAINER Ian Lintner <ian.lintner@workiva.com>

RUN a2enmod rewrite

# install the PHP extensions we need
RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev libpq-dev \
	&& rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mbstring opcache pdo pdo_mysql pdo_pgsql zip

# Drush
WORKDIR /tmp
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer


RUN export PATH="$HOME/.composer/vendor/bin:$PATH"
RUN echo "export PATH=\"$HOME/.composer/vendor/bin:$PATH\"" >> ~/.bashrc
RUN composer global require drush/drush:dev-master
RUN composer global update
RUN ln -sf ~/.composer/vendor/bin/drush /usr/bin/drush



# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

ENV TERM xterm
WORKDIR /var/www/html
