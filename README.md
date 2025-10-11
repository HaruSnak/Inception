<img src="readme/inception.png" alt="inception" width="900"/>

---

# Inception
So here we are at the Inception project, a complete system administration exercise focused on containerization and Docker infrastructure. This project involves setting up a small multi-service infrastructure using **Docker Compose**, **NGINX with TLS**, **WordPress with php-fpm**, and **MariaDB**, all configured from scratch following best practices.

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

---

## 📒 Index

- [About](#about)
    - [Implemented Features](#implemented-features)
	- [Architecture](#architecture)
	- [Technologies Used](#technologies-used)
- [Installation](#installation)
- [Testing](#testing)
- [Development](#development)
  - [File Structure](#file-structure)
  - [Diagram Architecture](#diagram-architecture)
- [Notes](#notes)
- [Credits](#credits)

---

## About

This is a solo project completed as part of the 42 School curriculum. Inception challenges students to build a containerized infrastructure from the ground up, emphasizing Docker best practices, security, and system administration skills.

The project demonstrates proficiency in:
- **Docker containerization** : Creating custom Docker images without using pre-built solutions
- **Service orchestration** : Managing multiple services with Docker Compose
- **Network configuration** : Setting up isolated networks and secure communications
- **TLS/SSL encryption** : Implementing HTTPS with TLSv1.2/1.3
- **WordPress deployment** : Installing and configuring WordPress with php-fpm
- **Database management** : Setting up MariaDB with secure user management
- **Volume persistence** : Managing data persistence with Docker volumes

All services are built from Debian Bullseye base images, configured with custom Dockerfiles, and orchestrated to work together seamlessly in an isolated Docker network.

---

## Implemented Features

### Mandatory Part

#### Docker Infrastructure
- **Custom Docker Images** : All images built from Debian Bullseye (no DockerHub pre-built images)
- **Docker Compose** : Complete orchestration of all services
- **Isolated Network** : Custom bridge network for inter-container communication
- **Volume Persistence** : Two volumes for database and WordPress files mounted on host
- **Auto-restart** : Containers configured to restart automatically on crash

#### NGINX Container
- **TLS 1.2/1.3 Only** : Secure HTTPS configuration with self-signed SSL certificates
- **Reverse Proxy** : Single entry point to infrastructure via port 443
- **PHP-FPM Integration** : FastCGI configuration for WordPress
- **Security Headers** : X-Frame-Options, X-Content-Type-Options, X-XSS-Protection
- **Static File Caching** : Optimized caching for CSS, JS, and images

#### WordPress Container
- **PHP-FPM 7.4** : Configured without NGINX, pure FastCGI processing
- **WP-CLI Integration** : Automated WordPress installation and configuration
- **Two Users** : Administrator (webmaster) and regular user
- **Database Connection** : Automated setup and connection to MariaDB
- **Volume Mounting** : WordPress files persisted on host at `/home/shmoreno/data/wordpress`

#### MariaDB Container
- **Database Initialization** : Automated database and user creation
- **Secure Configuration** : Root password protection, remote access control
- **Data Persistence** : Database files stored on host at `/home/shmoreno/data/mariadb`
- **Network Isolation** : Only accessible from WordPress container

### Security Features
- **No Hardcoded Passwords** : All credentials stored in environment variables and secrets
- **Environment Variables** : `.env` file for configuration
- **Secrets Management** : Separate files for sensitive credentials
- **No Hacky Patches** : Proper daemon management (no `tail -f`, `sleep infinity`)
- **PID 1 Best Practices** : Foreground processes with proper signal handling

---

## Architecture

The infrastructure follows a microservices pattern with three isolated containers:

```
Host Machine (shmoreno.42.fr:443)
         ↓
    [NGINX Container]
    Port 443 (HTTPS)
    TLSv1.2/1.3
         ↓
    [WordPress Container]
    Port 9000 (PHP-FPM)
         ↓
    [MariaDB Container]
    Port 3306 (MySQL)
```

- **Entry Point** : NGINX is the sole external-facing service on port 443
- **WordPress** : Processes PHP requests from NGINX via FastCGI
- **MariaDB** : Provides database backend for WordPress
- **Network** : All services communicate on `inception_network` bridge
- **Volumes** : Data persisted on host filesystem for database and WordPress files

---

## Technologies Used

- **Containerization** : Docker, Docker Compose
- **Web Server** : NGINX with SSL/TLS
- **Application** : WordPress 6.x, PHP 7.4-FPM
- **Database** : MariaDB 10.x
- **OS** : Debian Bullseye
- **Tools** : WP-CLI, OpenSSL, Bash scripting
- **Security** : TLSv1.2/1.3, Environment variables, Docker secrets

---

## Installation

### Prerequisites
- Docker and Docker Compose installed
- Sudo privileges for volume directory creation
- At least 2GB free disk space

### Setup
```bash
# Clone this repository
$ git clone https://github.com/HaruSnak/Inception
$ cd Inception

# Configure your domain in /etc/hosts
$ sudo bash srcs/requirements/tools/setup_hosts.sh
# Or manually add: 127.0.0.1 shmoreno.42.fr

# Build and start all services
$ make all

# Access WordPress
# Open your browser: https://shmoreno.42.fr
# (Accept the self-signed certificate warning)
```

### Environment Variables
The `.env` file in `srcs/` contains all configuration:
```env
DOMAIN_NAME=shmoreno.42.fr
MYSQL_ROOT_PASSWORD=rootpassword123
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=userpassword123
WP_ADMIN_USER=webmaster
WP_ADMIN_PASSWORD=adminpass123
WP_ADMIN_EMAIL=webmaster@shmoreno.42.fr
WP_USER=normaluser
WP_USER_EMAIL=user@shmoreno.42.fr
WP_USER_PASSWORD=userpass123
```

---

## Testing

### Service Verification
```bash
# Check all containers are running
$ docker ps

# Expected output:
# - nginx (port 443)
# - wordpress (port 9000)
# - mariadb (port 3306)

# Check container logs
$ make logs

# Verify volumes
$ ls -la /home/shmoreno/data/wordpress
$ ls -la /home/shmoreno/data/mariadb
```

### Functional Tests
```bash
# Test HTTPS connection
$ curl -k https://shmoreno.42.fr

# Test TLS version (should only accept 1.2 and 1.3)
$ openssl s_client -connect shmoreno.42.fr:443 -tls1_1  # Should fail
$ openssl s_client -connect shmoreno.42.fr:443 -tls1_2  # Should succeed

# Test database connection from WordPress container
$ docker exec wordpress mysqladmin ping -hmariadb -uwpuser -puserpassword123
```

### Manual Tests
1. **WordPress Access** : Navigate to https://shmoreno.42.fr
2. **Login** : Use `webmaster` / `adminpass123` for admin access
3. **Create Post** : Verify database persistence
4. **Restart Test** : Run `docker restart mariadb` and verify WordPress still works
5. **Volume Persistence** : Run `make down && make up`, data should persist

---

## Development

### File Structure

```
.
└── 📁Inception
    ├── Makefile
    ├── README.md
    └── 📁secrets
        ├── credentials.txt
        ├── db_password.txt
        └── db_root_password.txt
    └── 📁srcs
        ├── .env
        ├── docker-compose.yml
        └── 📁requirements
            └── 📁mariadb
                ├── Dockerfile
                └── 📁conf
                    └── 50-server.cnf
                └── 📁tools
                    └── entrypoint.sh
            └── 📁nginx
                ├── Dockerfile
                └── 📁conf
                    └── nginx.conf
                └── 📁tools
                    └── entrypoint.sh
            └── 📁wordpress
                ├── Dockerfile
                └── 📁conf
                    └── www.conf
                └── 📁tools
                    └── entrypoint.sh
            └── 📁tools
                └── setup_hosts.sh
```

### Diagram Architecture

```
┌─────────────────────────────────────────────────────┐
│              Host Machine (shmoreno)                 │
│  ┌─────────────────────────────────────────────┐   │
│  │         /home/shmoreno/data/                 │   │
│  │  ├── wordpress/  (Volume)                    │   │
│  │  └── mariadb/    (Volume)                    │   │
│  └─────────────────────────────────────────────┘   │
│                                                      │
│  ┌─────────────────────────────────────────────┐   │
│  │      Docker Network (inception_network)      │   │
│  │                                               │   │
│  │  ┌──────────────┐                            │   │
│  │  │    NGINX     │ :443 (HTTPS TLS 1.2/1.3)  │◄──┼─── Internet
│  │  │  Container   │                            │   │
│  │  └──────┬───────┘                            │   │
│  │         │ FastCGI (9000)                     │   │
│  │         ↓                                     │   │
│  │  ┌──────────────┐                            │   │
│  │  │  WordPress   │                            │   │
│  │  │  Container   │ PHP-FPM                    │   │
│  │  │              │                            │   │
│  │  └──────┬───────┘                            │   │
│  │         │ MySQL (3306)                       │   │
│  │         ↓                                     │   │
│  │  ┌──────────────┐                            │   │
│  │  │   MariaDB    │                            │   │
│  │  │  Container   │                            │   │
│  │  └──────────────┘                            │   │
│  └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

---

## Notes

### Important Considerations
- **Domain Configuration** : Ensure `shmoreno.42.fr` points to `127.0.0.1` in `/etc/hosts`
- **SSL Certificates** : Self-signed certificates are generated automatically during build
- **Data Persistence** : Volumes must be created in `/home/shmoreno/data/` before starting
- **No Latest Tag** : All images specify exact versions or use base Debian
- **PID 1 Compliance** : All services run in foreground mode for proper Docker behavior

### Common Issues
- **Permission Denied** : Run `make fclean` with sudo if volume cleanup fails
- **Port 443 Busy** : Check if another service is using port 443 (`sudo lsof -i :443`)
- **Database Connection Failed** : Wait 10-15 seconds after `make up` for MariaDB initialization
- **SSL Warning** : Browser will show warning for self-signed cert - this is expected

### Makefile Commands
```bash
make all      # Build and start all services
make build    # Build Docker images
make up       # Start containers
make down     # Stop containers
make clean    # Stop and remove containers/images
make fclean   # Full cleanup including volumes
make re       # Rebuild everything from scratch
make logs     # Follow container logs
make status   # Show container status
```

---

## Credits

Project developed as part of 42 School curriculum.

### Resources
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress CLI](https://wp-cli.org/)
- [MariaDB Documentation](https://mariadb.org/documentation/)
- [Debian Packages](https://packages.debian.org/)

### License
This project is licensed under the MIT License.

---

[contributors-shield]: https://img.shields.io/github/contributors/HaruSnak/Inception.svg?style=for-the-badge
[contributors-url]: https://github.com/HaruSnak/Inception/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/HaruSnak/Inception.svg?style=for-the-badge
[forks-url]: https://github.com/HaruSnak/Inception/network/members
[stars-shield]: https://img.shields.io/github/stars/HaruSnak/Inception.svg?style=for-the-badge
[stars-url]: https://github.com/HaruSnak/Inception/stargazers
[issues-shield]: https://img.shields.io/github/issues/HaruSnak/Inception.svg?style=for-the-badge
[issues-url]: https://github.com/HaruSnak/Inception/issues
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/in/shany-moreno-5a863b2aa