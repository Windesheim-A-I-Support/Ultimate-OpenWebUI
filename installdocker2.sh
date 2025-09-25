#!/bin/bash
set -uo pipefail

GREEN='\033[1;32m'
RED='\033[1;31m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Error tracking
ERRORS=()
ERROR_COUNT=0

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { 
    echo -e "${RED}[ERROR]${NC} $1" >&2
    ERRORS+=("$1")
    ((ERROR_COUNT++))
}
section() { echo -e "\n${BLUE}==== $1 ====${NC}"; }

# Docker Hub credentials (CHANGE PASSWORD FIRST!)
DOCKER_USERNAME="kamitor077"

# Safe execution function
safe_execute() {
    local command="$1"
    local description="${2:-command}"
    
    if eval "$command"; then
        log "$description completed successfully"
        return 0
    else
        error "Failed to execute: $description"
        return 1
    fi
}

section "Enhanced Docker Installation Script for Debian 12 (Root)"

# Confirm we're running as root
if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root on Debian 12"
    exit 1
fi

# Detect OS
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_CODENAME
    log "Detected OS: $OS $VER"
else
    error "Cannot detect OS. This script is designed for Debian 12."
    exit 1
fi

if [[ "$OS" != "debian" ]]; then
    error "This script is designed for Debian 12. Detected: $OS"
    exit 1
fi

if [[ "$VER" != "bookworm" ]]; then
    warn "Expected Debian 12 (bookworm), but detected: $VER. Continuing anyway..."
fi

section "Cleanup Previous Installations"
log "Cleaning up any existing Docker repositories and keys..."
rm -f /etc/apt/keyrings/docker.gpg 2>/dev/null || true
rm -f /etc/apt/keyrings/docker.asc 2>/dev/null || true
rm -f /etc/apt/sources.list.d/docker.list 2>/dev/null || true
rm -f /usr/share/keyrings/docker-archive-keyring.gpg 2>/dev/null || true

# Remove old Docker packages
log "Removing old Docker packages if they exist..."
apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

section "Docker Installation Check"
# Check if Docker is already installed and working
if command -v docker &> /dev/null; then
    log "Docker is already installed. Version: $(docker --version)"
    if docker compose version &> /dev/null; then
        log "Docker Compose plugin is already installed. Version: $(docker compose version)"
        log "Testing with hello-world..."
        if docker run --rm hello-world 2>/dev/null; then
            log "Docker is working correctly!"
            section "Docker Login Setup"
            setup_docker_login
            if [[ $ERROR_COUNT -eq 0 ]]; then
                log "Docker installation verification completed successfully"
                exit 0
            else
                log "Docker is functional but encountered $ERROR_COUNT minor issues"
                exit $ERROR_COUNT
            fi
        else
            warn "Docker is installed but not working properly. Continuing with reinstallation..."
        fi
    fi
fi

section "Installing Prerequisites"
log "Updating package index and installing prerequisites..."
safe_execute "apt-get update -y" "package index update"

log "Installing required packages..."
safe_execute "apt-get install -y ca-certificates curl gnupg lsb-release apt-transport-https software-properties-common" "prerequisite installation"

section "Docker Repository Setup"
# Create keyrings directory with proper permissions
log "Setting up keyrings directory..."
safe_execute "install -m 0755 -d /etc/apt/keyrings" "keyrings directory creation"

# Add Docker's official GPG key
log "Adding Docker GPG key for Debian..."
if curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg; then
    chmod a+r /etc/apt/keyrings/docker.gpg
    log "Docker GPG key added successfully"
else
    error "Failed to add Docker GPG key"
fi

# Add Docker repository
log "Adding Docker repository for Debian bookworm..."
if echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null; then
    log "Docker repository added successfully"
else
    error "Failed to add Docker repository"
fi

section "Docker Installation"
# Update package index with new repository
safe_execute "apt-get update -y" "package index update with Docker repository"

# Install Docker CE and all components
log "Installing Docker CE, CLI, and plugins..."
if apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
    log "Docker packages installed successfully"
else
    error "Docker package installation failed"
    exit 1
fi

section "Post-Installation Configuration"
# Enable and start Docker service
log "Enabling and starting Docker service..."
safe_execute "systemctl enable docker" "Docker service enable"
safe_execute "systemctl start docker" "Docker service start"

# Verify Docker daemon is running
if systemctl is-active --quiet docker; then
    log "Docker service is running"
else
    error "Docker service failed to start"
fi

section "Installation Verification"
# Test Docker installation
log "Testing Docker installation with hello-world..."
if docker run --rm hello-world; then
    log "Docker installation test successful!"
else
    error "Docker installation test failed"
fi

# Configure Docker daemon for optimal settings in privileged LXC
log "Configuring Docker daemon for privileged LXC environment..."
if [[ ! -f /etc/docker/daemon.json ]]; then
    cat > /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF
    safe_execute "systemctl restart docker" "Docker daemon restart after configuration"
    log "Docker daemon configured with optimized settings for privileged LXC"
else
    log "Docker daemon.json already exists, skipping configuration"
fi

section "Privileged Container Verification"
# Verify we're in a privileged container and Docker should work without warnings
if [[ -f /proc/1/environ ]] && grep -q container=lxc /proc/1/environ; then
    log "LXC container detected"
    # Check if we're privileged (no user namespace)
    if [[ ! -f /proc/self/uid_map ]] || [[ "$(cat /proc/self/uid_map 2>/dev/null)" == "0 0 4294967295" ]]; then
        log "Privileged LXC container confirmed - Docker should work without OverlayFS warnings"
    else
        warn "This appears to be an unprivileged container - you may still see OverlayFS warnings"
    fi
fi

section "Docker Login Setup"
setup_docker_login() {
    log "Setting up Docker Hub login..."
    warn "SECURITY REMINDER: Use personal access tokens instead of passwords when possible"
    
    echo
    read -p "Do you want to login to Docker Hub now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "Logging in as '$DOCKER_USERNAME'..."
        echo "Enter your Docker Hub password (or personal access token):"
        if docker login -u "$DOCKER_USERNAME"; then
            log "Successfully logged in to Docker Hub!"
        else
            error "Docker login failed"
        fi
    else
        log "Skipping Docker Hub login. Login later with: docker login"
    fi
}

setup_docker_login

section "Installation Summary"
# Display versions and information
if [[ $ERROR_COUNT -eq 0 ]]; then
    log "Docker installation completed successfully!"
else
    warn "Docker installation completed with $ERROR_COUNT error(s):"
    for error in "${ERRORS[@]}"; do
        echo -e "${RED}  ✗${NC} $error"
    done
fi

log "Installation details:"
echo "  Docker version: $(docker --version 2>/dev/null || echo 'Not available')"
echo "  Docker Compose version: $(docker compose version --short 2>/dev/null || echo 'Not available')"
echo "  Docker Buildx version: $(docker buildx version --short 2>/dev/null || echo 'Not available')"
echo "  Storage driver: $(docker info --format '{{.Driver}}' 2>/dev/null || echo 'Unknown')"

section "Privileged Container Benefits"
log "Expected improvements in privileged LXC container:"
echo "  ✓ No OverlayFS file handle warnings"
echo "  ✓ Better Docker performance"
echo "  ✓ Full overlay2 storage driver support"
echo "  ✓ No ZFS compatibility issues"

section "Quick Start Guide"
log "Common Docker commands:"
echo "  docker run hello-world                    # Test Docker"
echo "  docker images                             # List images"
echo "  docker ps                                 # List running containers"
echo "  docker ps -a                              # List all containers"
echo "  docker compose up -d                      # Start compose services"
echo "  docker system prune                       # Clean up unused resources"
echo "  docker login                              # Login to Docker Hub"

section "Cleanup"
log "Cleaning up package cache..."
safe_execute "apt-get autoremove -y" "package cleanup"
safe_execute "apt-get autoclean" "cache cleanup"

section "Final Status"
if [[ $ERROR_COUNT -eq 0 ]]; then
    log "Docker installation completed successfully with no errors!"
    log "Your privileged LXC container is ready for Docker workloads without OverlayFS warnings."
else
    warn "Installation completed with $ERROR_COUNT errors, but Docker should still be functional"
fi

exit $ERROR_COUNTocker "$USER"

# Enable and start Docker service
log "Enabling and starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Verify Docker daemon is running
if ! sudo systemctl is-active --quiet docker; then
    fail "Docker service failed to start"
fi

section "Installation Verification"
# Test Docker installation
log "Testing Docker installation with hello-world..."
if sudo docker run --rm hello-world; then
    log "Docker installation test successful!"
else
    fail "Docker installation test failed"
fi

# Configure Docker daemon for better performance (optional)
log "Configuring Docker daemon settings..."
if [[ ! -f /etc/docker/daemon.json ]]; then
    sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF
    sudo systemctl restart docker
    log "Docker daemon configured with optimized settings"
fi

section "Docker Login Setup"
setup_docker_login() {
    log "Setting up Docker Hub login..."
    warn "SECURITY NOTICE: Never store passwords in plain text!"
    warn "It's recommended to use personal access tokens instead of passwords."
    
    echo
    read -p "Do you want to login to Docker Hub now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "Logging in as '$DOCKER_USERNAME'..."
        echo "Please enter your Docker Hub password (or personal access token):"
        if docker login -u "$DOCKER_USERNAME"; then
            log "Successfully logged in to Docker Hub!"
        else
            warn "Docker login failed. You can login later with: docker login"
        fi
    else
        log "Skipping Docker Hub login. You can login later with: docker login"
    fi
}

setup_docker_login

section "Final Information"
# Display versions and important info
log "Installation Summary:"
echo "  Docker version: $(docker --version)"
echo "  Docker Compose version: $(docker compose version)"
echo "  Docker Buildx version: $(docker buildx version)"

section "Important Next Steps"
log "Post-installation actions required:"
echo "  1. Log out and log back in (or restart) for docker group membership to take effect"
echo "  2. After relogging, test with: docker run hello-world"
echo "  3. Change your Docker Hub password if it was compromised"
echo "  4. Consider enabling Docker Hub two-factor authentication"
echo "  5. Use personal access tokens instead of passwords for automation"

section "Useful Docker Commands"
log "Common Docker commands to get started:"
echo "  docker run hello-world                    # Test Docker"
echo "  docker images                             # List images"
echo "  docker ps                                 # List running containers"
echo "  docker ps -a                              # List all containers"
echo "  docker compose up -d                      # Start compose services"
echo "  docker system prune                       # Clean up unused resources"

section "Cleanup"
log "Cleaning up package cache..."
sudo apt-get autoremove -y
sudo apt-get autoclean

section "Installation Complete"
log "Docker installation completed successfully!"
log "The privileged LXC container should now support Docker without OverlayFS warnings."

# Check if we're in an LXC container
if [[ -f /proc/1/environ ]] && grep -q container=lxc /proc/1/environ; then
    log "LXC container detected - Docker should work without filesystem warnings in privileged mode"
fi