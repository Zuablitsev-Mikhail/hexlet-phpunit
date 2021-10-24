FROM php:8.0-fpm
MAINTAINER Mikhail Ziablitsev <mzuablitsev@gmail.com>

RUN apt-get update && apt-get install -y \
  cron \
  git \
  gzip \
  libfreetype6-dev \
  libicu-dev \
  libjpeg62-turbo-dev \
  libmcrypt-dev \
  libpng-dev \
  libxslt1-dev \
  lsof \
  default-mysql-client \
  vim \
  mc \
  zip \
  libmcrypt-dev \
  libonig-dev \
  libzip-dev

RUN docker-php-ext-configure \
  gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/

RUN docker-php-ext-install \
  bcmath \
  gd \
  intl \
  opcache \
  mbstring \
  pdo_mysql \
  soap \
  xsl \
  zip

RUN docker-php-ext-install sockets

RUN echo "deb http://deb.debian.org/debian stretch-backports main" >> /etc/apt/sources.list

RUN apt-get -y install libsodium23 libsodium-dev

RUN apt-get update && apt-get -t stretch-backports install -y \
  libsodium-dev

RUN pecl install -f libsodium-2.0.23

RUN pecl install mcrypt-1.0.4 && docker-php-ext-enable mcrypt

RUN pecl channel-update pecl.php.net \
  && pecl install -f xdebug \
  && docker-php-ext-enable xdebug \
  && sed -i -e 's/^zend_extension/\;zend_extension/g' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN apt-get install -y libssh2-1-dev \
  && pecl install ssh2-1.3.1 \
  && docker-php-ext-enable ssh2

RUN curl -sS https://getcomposer.org/installer | \
   php -- --version=2.1.9 --install-dir=/usr/local/bin --filename=composer

RUN groupadd -g 1000 app \
 && useradd -g 1000 -u 1000 -d /var/www -s /bin/bash app

RUN if [ ${INSTALL_GNUPG} = true ]; then \
      apt-get -yq install libgpgme-dev; \
      if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ]; then \
        pecl install gnupg-1.5.0RC2; \
      else \
        pecl install gnupg; \
      fi; \
      docker-php-ext-enable gnupg; \
      php -m | grep -q 'gnupg'; \
    fi

RUN curl -sLc https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs
RUN mkdir /var/www/.config /var/www/.npm
RUN chown app:app /var/www/.config /var/www/.npm
RUN ln -s /var/www/html/node_modules/grunt/bin/grunt /usr/bin/grunt

RUN curl -sSLO https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 \
  && chmod +x mhsendmail_linux_amd64 \
  && mv mhsendmail_linux_amd64 /usr/local/bin/mhsendmail

RUN ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime && dpkg-reconfigure -f noninteractive tzdata


COPY conf/www.conf /usr/local/etc/php-fpm.d/
COPY conf/php.ini /usr/local/etc/php/
COPY conf/php-fpm.conf /usr/local/etc/
#COPY bin/cronstart /usr/local/bin/

RUN mkdir -p /etc/nginx/html /var/www/html /sock
RUN chown -R app:app /etc/nginx /var/www /usr/local/etc/php/conf.d /sock

USER app:app

VOLUME /var/www

WORKDIR /var/www/html

EXPOSE 9001