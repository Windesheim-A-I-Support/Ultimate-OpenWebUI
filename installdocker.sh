#!/bin/bash
set -e

echo "=== Enhanced Docker Installation Script ==="

# Detect OS
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_CODENAME
else
    echo "Cannot detect OS. This script supports Ubuntu and Debian only."
    exit 1
fi

if [[ "$OS" != "ubuntu" && "$OS" != "debian" ]]; then
    echo "Unsupported OS: $OS. This script supports Ubuntu and Debian only."
    exit 1
fi

echo "Detected OS: $OS $VER"

# Remove any existing Docker keys/repos that might cause conflicts
echo "Cleaning up any existing Docker repositories and keys..."
sudo rm -f /etc/apt/keyrings/docker.gpg 2>/dev/null || true
sudo rm -f /etc/apt/keyrings/docker.asc 2>/dev/null || true
sudo rm -f /etc/apt/sources.list.d/docker.list 2>/dev/null || true
sudo rm -f /usr/share/keyrings/docker-archive-keyring.gpg 2>/dev/null || true

# Check if Docker is already installed
if command -v docker &> /dev/null; then
    echo "Docker is already installed. Version: $(docker --version)"
    echo "Checking if docker-compose plugin is installed..."
    if docker compose version &> /dev/null; then
        echo "Docker Compose plugin is already installed. Version: $(docker compose version)"
        echo "Installation appears complete. Testing with hello-world..."
        docker run --rm hello-world
        exit 0
    fi
fi

echo "Installing/updating Docker CE..."

# Install prerequisites
echo "Installing prerequisites..."
sudo apt-get update -y
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    apt-transport-https

# Create keyrings directory
sudo install -m 0755 -d /etc/apt/keyrings

# Add Docker's official GPG key (OS-specific)
echo "Adding Docker GPG key for $OS..."
sudo curl -fsSL https://download.docker.com/linux/$OS/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository (OS-specific)
echo "Adding Docker repository for $OS..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$OS \
  $VER stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index
sudo apt-get update -y

# Install Docker CE and plugins
echo "Installing Docker CE, CLI, and plugins..."
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Add current user to docker group
echo "Adding user '$USER' to docker group..."
sudo usermod -aG docker "$USER"

# Enable and start Docker service
echo "Enabling and starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Test Docker installation
echo "Testing Docker installation..."
sudo docker run --rm hello-world

# Display versions
echo ""
echo "=== Installation Complete ==="
echo "Docker version: $(docker --version)"
echo "Docker Compose version: $(docker compose version)"
echo ""
echo "IMPORTANT: You need to log out and log back in (or restart) for docker group membership to take effect."
echo "After that, you can run docker commands without sudo."
echo ""
echo "To test after relogging: docker run hello-world"
echo ""

# Cleanup
echo "Cleaning up package cache..."
sudo apt-get autoremove -y
sudo apt-get autoclean

echo "Docker installation completed successfully!"