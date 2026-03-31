#!/bin/bash
set -e

if [ ! -f /run/secrets/db_password ] || [ ! -f /run/secrets/credentials ]; then
    echo "Error: secrets not found"
    exit 1
fi

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/credentials)

cd /var/www/html

if [ ! -f wp-config.php ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root

    echo "Configuring WordPress..."
    wp config create --allow-root \
        --dbname=wordpress \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost=mariadb:3306

    echo "Installing WordPress..."
    wp core install --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}"

    echo "Creating second user..."
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${DB_PASSWORD}" \
        --allow-root

    chown -R www-data:www-data /var/www/html

    echo "WordPress install completed"
fi

exec php-fpm8.2 -F