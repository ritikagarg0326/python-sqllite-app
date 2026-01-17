# Docker Commands Repo

[![CI/CD Pipeline](https://github.com/ritikagarg0326/docker-commands/actions/workflows/main.yml/badge.svg)](https://github.com/ritikagarg0326/docker-commands/actions/workflows/main.yml)

A collection of Docker commands and project examples for learning and automation.

# 🐳 Docker Commands Cheatsheet

This repository contains all the commonly used Docker commands with explanations and examples.

---

## 🔹 1. Docker Basics
```bash
docker --version        # Check Docker version
docker info             # Show system-wide Docker information
docker help             # Show help for Docker
```

## 🔹 2. Images
```bash
docker images                 # List images
docker pull <image>           # Download an image from Docker Hub
docker build -t myapp .       # Build image from Dockerfile
docker rmi <image_id>         # Remove image
docker tag <image> <repo:tag> # Tag image
```

## 🔹 3. Containers
```bash
docker ps                     # List running containers
docker ps -a                  # List all containers
docker run hello-world        # Run a container
docker run -it ubuntu bash    # Run container interactively
docker stop <container_id>    # Stop container
docker start <container_id>   # Start container
docker restart <container_id> # Restart container
docker rm <container_id>      # Remove container
docker logs <container_id>    # Show logs
docker exec -it <container_id> bash  # Access running container
```

## 🔹 4. Volumes
```bash
docker volume create myvolume       # Create volume
docker volume ls                    # List volumes
docker run -v myvolume:/data ubuntu # Mount volume
docker volume rm myvolume           # Remove volume
```

## 🔹 5. Networks
```bash
docker network ls                      # List networks
docker network create mynetwork        # Create network
docker run -d --network=mynetwork app  # Run container in custom network
docker network inspect mynetwork       # Inspect network
```

## 🔹 6. Docker Compose
```bash
docker-compose up -d      # Start services
docker-compose down       # Stop and remove services
docker-compose ps         # List services
docker-compose logs -f    # Show logs
```

## 🔹 7. Docker System
```bash
docker system df      # Show disk usage
docker system prune   # Clean up unused objects
docker stats          # Show running containers stats
```

## 🔹 8. Docker Registry
```bash
docker login                          # Login to registry
docker tag myapp myrepo/myapp:latest  # Tag image
docker push myrepo/myapp:latest       # Push image
docker pull myrepo/myapp:latest       # Pull image
```

---

## 📌 Notes
- Replace `<image>`, `<container_id>`, `<volume>`, etc. with actual values.
- Use `docker --help` for more info on each command.

---

## 📂 Examples Included
- `examples/python-app/Dockerfile` → Simple Python app with Flask
- `examples/node-app/Dockerfile` → Simple Node.js app
- `examples/docker-compose.yml` → Multi-container setup (Python + Redis)

