# README
## Link to the video
https://drive.google.com/uc?id=12IFglsctNerLLgTGpyRTxFC8yVCukd7W&export=download
## Overview
This script sets up a Flask application inside a Docker container, configures Nginx as a reverse proxy, and secures the connection with a self-signed SSL certificate. It automates the process of installing necessary packages, building the Docker environment, and configuring Nginx to serve the Flask application.

## Prerequisites
- Ubuntu-based server
- Public IP address of the server
- Basic understanding of Docker, Docker Compose, and Nginx

## Usage

### Step-by-Step Instructions

1. **Clone your application repository**:
   Ensure you have your Flask application in a directory named `app`.

2. **Run the setup script**:
   Save the provided Bash script as `setup.sh` and run it:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. **Follow the prompts**:
   - Enter the public IP address of the server when prompted.

### Script Breakdown

1. **Prompt for the Public IP Address**:
   The script prompts the user to enter the public IP address of the server.
   ```bash
   read -p "Enter the public IP address of the server: " PUBLIC_IP
   ```

2. **Update Package List and Install Necessary Packages**:
   The script updates the package list and installs Docker, Docker Compose, Nginx, and OpenSSL.
   ```bash
   sudo apt update
   sudo apt install -y docker.io docker-compose-plugin nginx openssl
   ```

3. **Enable and Start Docker Service**:
   Docker service is enabled and started to run on boot.
   ```bash
   sudo systemctl enable docker
   sudo systemctl start docker
   ```

4. **Create Requirements File**:
   Creates `requirements.txt` file for Flask application dependencies.
   ```bash
   cd app
   sudo cat <<EOF | sudo tee -a requirements.txt
   Flask==3.0.3
   Werkzeug==3.0.3
   EOF
   ```

5. **Create Dockerfile**:
   Creates a Dockerfile for the Flask application.
   ```bash
   sudo cat <<EOF | sudo tee -a Dockerfile
   FROM python:3.8-slim

   WORKDIR /app

   COPY requirements.txt requirements.txt
   RUN pip install -r requirements.txt

   COPY . .

   CMD ["python", "app.py"]
   EOF
   ```

6. **Create Docker Compose File**:
   Creates a Docker Compose file to define the service.
   ```bash
   sudo cat <<EOF | sudo tee -a docker-compose.yml
   services:
     web:
       build: .
       ports:
         - "5000:5000"
   EOF
   ```

7. **Build and Run Docker Container**:
   Builds the Docker container and starts it in detached mode.
   ```bash
   sudo docker compose up -d
   ```

8. **Configure Nginx**:
   Configures Nginx to reverse proxy requests to the Flask application.
   ```bash
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
   sudo ln -s /etc/nginx/sites-available/app /etc/nginx/sites-enabled/
   ```

9. **Generate Self-Signed SSL Certificates**:
   Generates self-signed SSL certificates.
   ```bash
   sudo mkdir -p /etc/nginx/ssl
   sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/selfsigned.key -out /etc/nginx/ssl/selfsigned.crt -subj "/CN=$PUBLIC_IP"
   ```

10. **Test and Reload Nginx Configuration**:
    Tests the Nginx configuration and reloads it.
    ```bash
    sudo nginx -t
    sudo systemctl reload nginx
    ```

## Notes
- Ensure that port 80 and 443 are open and accessible from the public internet.
- This setup uses a self-signed SSL certificate, which is not suitable for production environments. For a production setup, obtain a certificate from a trusted certificate authority.
- Modify the `requirements.txt` and `Dockerfile` as needed for your specific application dependencies and Python version.

## License
This project is licensed under the MIT License. Feel free to use and modify the script as needed.

## Result
![image](https://github.com/aktan77/situational_task3/assets/120569380/5dc2a850-57ec-4b8e-a3e6-6c640a63512c)
![image](https://github.com/aktan77/situational_task3/assets/120569380/c44d6f8e-36b6-4982-a092-37c1852c1482)

## File system after script has run
![image](https://github.com/aktan77/situational_task3/assets/120569380/1b0e9b1e-0371-413c-9b17-7d82e1732f91)
