#!/bin/bash

NGINX_CONF_DIR="/etc/nginx/conf.d"
NGINX_CONF_FILE="$NGINX_CONF_DIR/reverse_proxy.conf"
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

# Function to check if Nginx is installed
function check_nginx_installed() {
    if command -v nginx &> /dev/null; then
        echo "Nginx is already installed."
        return 0
    else
        echo "Nginx is not installed."
        return 1
    fi
}

# Function to install Nginx
function install_nginx() {
    echo "Installing Nginx..."
    sudo apt-get update
    sudo apt-get install -y nginx
    echo "Nginx installation complete."
    enable_nginx_on_boot
}

# Function to enable Nginx to start on boot
function enable_nginx_on_boot() {
    echo "Enabling Nginx to start on boot..."
    sudo systemctl enable nginx
    echo "Nginx is now enabled to start on boot."
}

# Function to check if the configuration file already exists
function check_nginx_conf_exists() {
    if [ -f "$NGINX_CONF_FILE" ]; then
        echo "Configuration file already exists: $NGINX_CONF_FILE"
        return 0
    else
        echo "Configuration file does not exist: $NGINX_CONF_FILE"
        return 1
    fi
}

# Function to create Nginx configuration
function create_nginx_conf() {
    echo "Creating Nginx configuration file..."
    sudo mkdir -p "$NGINX_CONF_DIR"
    sudo bash -c "cat > $NGINX_CONF_FILE" <<EOL
server {
    listen 80;
    server_name $PUBLIC_IP;

    location / {
        proxy_pass http://localhost:8081;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL
    echo "Nginx configuration created at $NGINX_CONF_FILE."
}

# Function to restart Nginx
function restart_nginx() {
    echo "Testing Nginx configuration..."
    sudo nginx -t
    echo "Restarting Nginx..."
    sudo systemctl restart nginx
    echo "Nginx restarted successfully."
}

# Main script logic
if ! check_nginx_installed; then
    install_nginx
fi

if ! check_nginx_conf_exists; then
    create_nginx_conf
    restart_nginx
else
    echo "Skipping configuration creation since the file already exists."
fi

echo "Nginx setup and configuration process completed."
