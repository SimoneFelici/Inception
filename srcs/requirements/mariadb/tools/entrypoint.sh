#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

if [ ! -d "/var/lib/mysql/wordpress" ]; then
    echo "Initializing MariaDB data directory..."

    # Start temporarily to run setup queries
    mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking &
    pid=$!

    # Wait for MariaDB to be ready
    until mariadb -u root -e "SELECT 1" > /dev/null 2>&1; do
        sleep 1
    done

    mariadb -u root <<-EOF
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
        CREATE DATABASE IF NOT EXISTS wordpress;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
        GRANT ALL PRIVILEGES ON wordpress.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOF

    kill "$pid"
    wait "$pid"
    echo "MariaDB initialization complete."
fi

exec mariadbd --user=mysql --datadir=/var/lib/mysql