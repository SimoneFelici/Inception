# Developer Documentation

## Setting Up the Environment from Scratch

### Prerequisites

- A virtual machine running Debian (the project must be done inside a VM)
- Docker Engine and Docker Compose installed
- sudo access

### Configuration Files

- `srcs/.env` — environment variables (domain name, login, MySQL user, WordPress user info). This file is tracked by Git.
- `srcs/docker-compose.yml` — defines the three services, network, volumes, and secrets.
- `srcs/requirements/*/Dockerfile` — one Dockerfile per service, all based on `debian:oldstable`.
- `srcs/requirements/*/conf/` — configuration files for each service (MariaDB server config, NGINX virtual host, PHP-FPM pool).
- `srcs/requirements/*/tools/entrypoint.sh` — entrypoint scripts that initialize services at container startup.

### Secrets

Create the `secrets/` directory at the project root:
```
mkdir -p secrets
echo "your_db_password" > secrets/db_password.txt
echo "your_db_root_password" > secrets/db_root_password.txt
echo "your_wp_admin_password" > secrets/credentials.txt
```

These files are referenced in `docker-compose.yml` and mounted at `/run/secrets/` inside the containers. They must not be committed to Git.

### Host Configuration

Add the domain name to `/etc/hosts`:
```
sudo sh -c 'echo "127.0.0.1 sfelici.42.fr" >> /etc/hosts'
```

## Building and Launching

The Makefile at the project root handles everything:

```
make        # creates data directories and runs docker compose up --build
make stop   # stops containers
make start  # starts stopped containers
make down   # removes containers
make clean  # removes containers and prunes unused images
make fclean # full cleanup: removes containers, volumes, data, and prunes all images
make re     # fclean + all
```

The `make` command creates the host directories `/home/sfelici/data/mariadb` and `/home/sfelici/data/wordpress` before calling `docker compose up --build`.

## Managing Containers and Volumes

### Container commands

```
docker ps                          # list running containers
docker logs <container_name>       # view container logs
docker exec -it <container_name> bash  # open a shell inside a container
```

Container names are: `mariadb`, `wordpress`, `nginx`.

### Volume commands

```
docker volume ls                   # list all volumes
docker volume inspect mariadb_data # inspect a specific volume
docker volume inspect wordpress_data
```

### Restarting a single service

```
docker compose -f srcs/docker-compose.yml restart wordpress
```

### Full reset (data included)

```
make fclean
make
```

## Data Storage and Persistence

Data persists through Docker named volumes mapped to the host filesystem:

| Volume | Container path | Host path |
|--------|---------------|-----------|
| `mariadb_data` | `/var/lib/mysql` | `/home/sfelici/data/mariadb` |
| `wordpress_data` | `/var/www/html` | `/home/sfelici/data/wordpress` |

Both volumes use the `local` driver with `driver_opts` that bind to the host paths above. This means:

- Data survives container restarts and rebuilds (as long as volumes are not removed).
- `make down` stops and removes containers but keeps volumes and data.
- `make fclean` removes volumes and deletes data from the host directories, giving a clean slate.

### Initialization behavior

- **MariaDB**: the entrypoint checks if `/var/lib/mysql/mysql` exists. On first run, it initializes the database, creates the WordPress database and user, then starts `mariadbd`. On subsequent runs, it starts `mariadbd` directly.
- **WordPress**: the entrypoint checks if `wp-config.php` exists. On first run, it downloads WordPress, creates the config, installs the site, creates two users, and sets permissions. On subsequent runs, it starts `php-fpm8.2` directly.
- **NGINX**: the SSL certificate is generated at build time (hardcoded in the Dockerfile). The entrypoint simply starts `nginx` in foreground.
