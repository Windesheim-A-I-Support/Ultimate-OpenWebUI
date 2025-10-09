#!/bin/bash
# Enable SSH access (password + public key) on Debian/Ubuntu
# Safe to run multiple times — only makes changes if needed.

set -e

echo "=== Checking for OpenSSH Server ==="

# 1. Install OpenSSH Server only if not installed
if ! dpkg -s openssh-server >/dev/null 2>&1; then
    echo "OpenSSH server not found, installing..."
    sudo apt update -y && sudo apt install -y openssh-server
else
    echo "OpenSSH server already installed."
fi

# 2. Ensure SSH service is enabled and running
if ! systemctl is-enabled ssh >/dev/null 2>&1; then
    echo "Enabling ssh service..."
    sudo systemctl enable ssh
else
    echo "SSH service already enabled."
fi

if ! systemctl is-active ssh >/dev/null 2>&1; then
    echo "Starting ssh service..."
    sudo systemctl start ssh
else
    echo "SSH service already running."
fi

# 3. Update /etc/ssh/sshd_config safely
echo "Configuring sshd_config..."

sudo sed -i \
    -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' \
    -e 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' \
    -e 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' \
    -e 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' \
    /etc/ssh/sshd_config

# 4. Reload or restart SSH if config changed
echo "Restarting ssh service..."
sudo systemctl restart ssh

# 5. Confirm
echo
echo "=== SSH STATUS ==="
sudo systemctl status ssh --no-pager
echo
echo "✅ SSH is enabled with password and public key authentication."
