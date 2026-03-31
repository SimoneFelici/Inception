#!/bin/bash

set -e

# Generate self-signed certificate if not exists
if [ ! -f /etc/ssl/certs/nginx.crt ]; then
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/ssl/private/nginx.key \
        -out /etc/ssl/certs/nginx.crt \
        -subj "/CN=${DOMAIN_NAME}"
fi

# Replace domain name in nginx config
sed -i "s/\${DOMAIN_NAME}/${DOMAIN_NAME}/g" /etc/nginx/conf.d/default.conf

exec nginx -g "daemon off;"