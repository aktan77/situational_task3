#!/bin/bash

# Prompt for the public IP address
read -p "Enter the public IP address of the server: " PUBLIC_IP

# Update package list and install necessary packages
sudo apt update
sudo apt install -y docker.io docker-compose-plugin nginx openssl

# Enable and star docker service
sudo systemctl enable docker
sudo systemctl start docker

cd app

# Create requirements.txt file
sudo cat <<EOF | sudo tee -a requirements.txt
Flask==3.0.3
Werkzeug==2.2.2
EOF

# Create Dockerfile for Flask application
sudo cat <<EOF | sudo tee -a Dockerfile
FROM python:3.8-slim

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY . .

CMD ["python", "app.py"]
EOF

# Create Docker Compose file
sudo cat <<EOF | sudo tee -a docker-compose.yml
services:
  web:
    build: .
    ports:
      - "5000:5000"
EOF


# Build and run Docker container
sudo docker compose up -d

# Configure Nginx
sudo rm /etc/nginx/sites-enabled/default
sudo cat <<EOF | sudo tee -a /etc/nginx/sites-available/app
server {
    listen 80;
    server_name $PUBLIC_IP;

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    listen 443 ssl;
    ssl_certificate /etc/nginx/ssl/selfsigned.crt;
    ssl_certificate_key /etc/nginx/ssl/selfsigned.key;
}
EOF
# Enable the new Nginx configuration
sudo ln -s /etc/nginx/sites-available/app /etc/nginx/sites-enabled/

# Generate self-signed SSL certificates
sudo mkdir -p /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/selfsigned.key -out /etc/nginx/ssl/selfsigned.crt -subj "/CN=$PUBLIC_IP"

# Test and reload Nginx configuration
sudo nginx -t
sudo systemctl reload nginx

