# User Documentation

## Services Overview

This stack provides a WordPress website served over HTTPS. It is composed of three services:

- **NGINX** — web server and reverse proxy, handles HTTPS connections on port 443 with a self-signed TLS certificate.
- **WordPress + PHP-FPM** — the content management system that powers the website, processing PHP requests on port 9000 internally.
- **MariaDB** — the relational database that stores all WordPress content (posts, users, settings).

## Starting and Stopping the Project

Start the project (builds images if needed):
```
make
```

Stop the containers without removing them:
```
make stop
```

Restart stopped containers:
```
make start
```

Remove containers:
```
make down
```

Full cleanup (removes containers, volumes, and stored data):
```
make fclean
```

## Accessing the Website

Open a browser and navigate to:
```
https://sfelici.42.fr
```

The browser will show a certificate warning because the TLS certificate is self-signed. Accept the warning to proceed.

### WordPress Administration Panel

Access the admin dashboard at:
```
https://sfelici.42.fr/wp-admin
```

Log in with the administrator credentials (see below).

## Credentials

Passwords are stored in the `secrets/` directory at the project root. This directory is not tracked by Git and must be created manually on each machine.

- `secrets/credentials.txt` — WordPress administrator password
- `secrets/db_password.txt` — MariaDB user password (also used for the second WordPress user)
- `secrets/db_root_password.txt` — MariaDB root password

The WordPress administrator username and other non-sensitive settings are defined in `srcs/.env`.

To change a password, edit the corresponding file in `secrets/`, then rebuild the project with `make fclean && make` (this will reset all data).

## Checking That Services Are Running

List running containers:
```
docker ps
```

You should see three containers: `mariadb`, `wordpress`, and `nginx`, all with status "Up".

Check logs for a specific container:
```
docker logs mariadb
docker logs wordpress
docker logs nginx
```

Test the HTTPS connection:
```
curl -k https://sfelici.42.fr
```

This should return HTML content from the WordPress site.
