*This project has been created as part of the 42 curriculum by sfelici.*

# Inception

## Description

Inception is a system administration project that uses Docker to build a small web infrastructure from scratch. The goal is to set up three interconnected services — NGINX, WordPress with PHP-FPM, and MariaDB — each running in its own container, orchestrated via Docker Compose.

The infrastructure serves a WordPress website accessible over HTTPS (port 443 only) through an NGINX reverse proxy. All Docker images are custom-built from Debian, with no pre-made images pulled from Docker Hub.

### Project Description — Docker and Design Choices

This project relies entirely on Docker and Docker Compose to containerize and orchestrate the services. Each service (NGINX, WordPress, MariaDB) has its own Dockerfile built from `debian:oldstable`. The containers communicate through a dedicated Docker bridge network, and persistent data is stored using Docker named volumes mapped to the host filesystem at `/home/sfelici/data/`.

Sensitive credentials (database passwords, WordPress admin password) are managed through Docker secrets, stored in local files that are excluded from version control.

#### Virtual Machines vs Docker

Virtual machines emulate an entire operating system with its own kernel, consuming significant resources (RAM, CPU, disk). Docker containers share the host kernel and only isolate the application layer, making them much lighter and faster to start. VMs provide stronger isolation since each has a full OS, while containers trade some isolation for efficiency. For this project, Docker is the better fit because we need lightweight, reproducible services that can be built and torn down quickly.

#### Secrets vs Environment Variables

Environment variables are convenient for non-sensitive configuration (domain names, usernames) but are visible in process listings, logs, and container inspect output. Docker secrets mount sensitive data as files inside `/run/secrets/`, readable only by the container, and are never exposed in logs or environment dumps. This project uses environment variables for general config (`.env`) and secrets for all passwords.

#### Docker Network vs Host Network

Host networking removes network isolation — the container shares the host's network stack directly. This means containers can conflict on ports and there is no separation between services. A Docker bridge network creates an isolated virtual network where containers communicate by service name (DNS resolution) and only explicitly published ports are accessible from outside. This project uses a bridge network (`inception_network`) for proper isolation, with only port 443 exposed through NGINX.

#### Docker Volumes vs Bind Mounts

Bind mounts map a specific host path directly into a container, tightly coupling the container to the host filesystem. Docker named volumes are managed by Docker, offering better portability and lifecycle management. However, this project uses named volumes with `driver_opts` that point to `/home/sfelici/data/`, combining the management benefits of named volumes with a predictable host storage location as required by the subject.

## Instructions

### Prerequisites

- A virtual machine running Debian
- Docker and Docker Compose installed
- Root or sudo access

### Setup

1. Clone the repository
2. Add the domain to `/etc/hosts`:
   ```
   sudo sh -c 'echo "127.0.0.1 sfelici.42.fr" >> /etc/hosts'
   ```
3. Create the secrets directory at the project root with real passwords:
   ```
   mkdir -p secrets
   echo "your_db_password" > secrets/db_password.txt
   echo "your_db_root_password" > secrets/db_root_password.txt
   echo "your_wp_admin_password" > secrets/credentials.txt
   ```
4. Build and start everything:
   ```
   make
   ```
5. Access the website at `https://sfelici.42.fr`

### Other commands

- `make stop` — stop containers
- `make start` — restart stopped containers
- `make down` — remove containers
- `make clean` — remove containers and prune images
- `make fclean` — full cleanup including volumes and data
- `make re` — full rebuild

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress CLI handbook](https://make.wordpress.org/cli/handbook/)
- [PHP-FPM documentation](https://www.php.net/manual/en/install.fpm.php)
- [Debian Docker base image](https://hub.docker.com/_/debian)
- [OpenSSL self-signed certificates](https://www.openssl.org/docs/)

### AI Usage

AI (Claude) was used as a learning and productivity tool during this project for the following tasks:

- Understanding Docker Compose syntax and best practices for writing Dockerfiles
- Reviewing and debugging configuration files
- Comparing my setup against project requirements and identifying missing elements
- Writing boilerplate for entrypoint scripts and understanding PID 1 best practices

All AI-generated content was reviewed, tested, and understood before being integrated into the project.
