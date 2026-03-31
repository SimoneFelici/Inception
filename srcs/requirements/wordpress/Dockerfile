FROM debian:oldstable

RUN apt-get update -y && apt-get install -y \
    php php-fpm php-mysql php-curl php-gd php-mbstring php-xml php-zip \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/php \
    && chown -R www-data:www-data /var/www/html

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]