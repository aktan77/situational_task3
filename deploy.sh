#!/bin/bash

# Prompt for the public IP address
read -p "Enter the public IP address of the server: " PUBLIC_IP

# Update package list and install necessary packages
sudo apt update
sudo apt install -y docker.io docker-compose nginx openssl

# Enable and star docker service
sudo systemctl enable docker
sudo systemctl start docker

cd app

# Create requirements.txt file
cat <<EOF > requirements.txt
Flask==2.0.1
EOF

# Create Dockerfile for Flask application
cat <<EOF > Dockerfile
FROM python:3.8-slim

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY . .

CMD ["python", "app.py"]
EOF

# Create Docker Compose file
cat <<EOF > docker-compose.yml
version: '3'
services:
  web:
    build: .
    ports:
      - "5000:5000"
EOF


# Build and run Docker container
sudo docker-compose up -d

