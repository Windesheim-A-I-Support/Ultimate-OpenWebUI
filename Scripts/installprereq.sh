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

# Function to safely install packages
safe_install() {
    local package_list="$1"
    local section_name="${2:-packages}"
    
    log "Installing $section_name..."
    if apt-get install -y $package_list; then
        log "$section_name installed successfully"
        return 0
    else
        error "Failed to install some $section_name packages: $package_list"
        return 1
    fi
}

# Function to safely execute commands
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

section "System Update & Core Packages"
log "Updating base system packages..."
safe_execute "apt-get update -y" "package index update"
safe_execute "apt-get upgrade -y" "system upgrade"

log "Installing essential system packages..."
safe_install "curl wget gnupg lsb-release ca-certificates apt-transport-https software-properties-common" "essential packages"

section "Network & System Utilities"
safe_install "net-tools netcat-openbsd nmap iptables ufw dnsutils traceroute iputils-ping telnet whois iproute2 bridge-utils" "network utilities"
safe_install "tcpdump iftop nethogs" "network monitoring tools"

section "File & Archive Management"
safe_install "unzip zip tar gzip bzip2 xz-utils p7zip-full tree file rsync" "file management tools"
safe_install "rclone" "cloud sync tools"

section "Text Editors & Development Tools"
safe_install "nano vim git jq build-essential make gcc" "editors and build tools"
safe_install "python3 python3-pip python3-venv" "Python development"
safe_install "nodejs npm" "Node.js development"
safe_install "golang-go" "Go development"

# Try to install yq, but it might not be available in all repos
if ! safe_install "yq" "YAML processor"; then
    warn "yq not available in repositories, skipping..."
fi

section "System Monitoring & Performance"
safe_install "htop iotop atop nmon sysstat lsof strace psmisc procps cron logrotate" "monitoring tools"
safe_install "fail2ban" "security monitoring"

section "Terminal & Session Management"
safe_install "tmux screen bash-completion zsh fish neofetch figlet" "terminal utilities"
safe_install "cowsay fortune-mod" "fun terminal tools"

section "Security & Access Control"
safe_install "sudo acl openssh-server ufw fail2ban" "security tools"
safe_install "clamav rkhunter chkrootkit" "security scanners"

section "Container & Virtualization Support"
safe_install "fuse3 fuse squashfs-tools systemd-container" "container support"
safe_install "crun runc" "container runtimes"

section "Database Clients"
safe_install "mysql-client postgresql-client redis-tools sqlite3" "database clients"

section "Web & HTTP Tools"
safe_install "apache2-utils nginx-extras" "web server utilities"
safe_install "certbot python3-certbot-nginx" "SSL certificate tools"
safe_install "lynx links" "text-based browsers"

section "Backup & Sync Tools"
safe_install "rsync" "basic sync tools"
# These might not be in all repositories
for tool in "borgbackup" "duplicity" "restic" "rdiff-backup"; do
    safe_install "$tool" "$tool backup tool" || true
done

section "Additional Utilities"
safe_install "bc dc units calendar at mailutils pandoc socat parallel pv dialog whiptail expect" "miscellaneous utilities"
# These might have dependencies that aren't available
for tool in "msmtp" "imagemagick" "ffmpeg"; do
    safe_install "$tool" "$tool utility" || true
done

section "System Configuration"
log "Configuring system settings..."

# Enable bash completion
if [[ -f /etc/bash_completion ]] && ! grep -q "bash_completion" ~/.bashrc; then
    echo "source /etc/bash_completion" >> ~/.bashrc
fi

# Configure git (if not already configured)
if ! git config --global user.name >/dev/null 2>&1; then
    git config --global user.name "kamitor"
    log "Git user.name configured as 'kamitor'"
else
    log "Git user.name already configured"
fi

if ! git config --global user.email >/dev/null 2>&1; then
    git config --global user.email "christiaan_gerardo@hotmail.com"
    log "Git user.email configured as 'christiaan_gerardo@hotmail.com'"
else
    log "Git user.email already configured"
fi

# Configure vim with basic settings
if [[ ! -f ~/.vimrc ]]; then
    cat > ~/.vimrc << 'EOF'
set number
set autoindent
set tabstop=4
set shiftwidth=4
set expandtab
syntax on
set hlsearch
set ignorecase
set smartcase
EOF
fi

# Configure tmux with basic settings
if [[ ! -f ~/.tmux.conf ]]; then
    cat > ~/.tmux.conf << 'EOF'
set -g mouse on
set -g history-limit 10000
set -g default-terminal "screen-256color"
bind-key | split-window -h
bind-key - split-window -v
EOF
fi

# Set up useful aliases
if ! grep -q "# Custom aliases" ~/.bashrc; then
    cat >> ~/.bashrc << 'EOF'

# Custom aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias h='history'
alias c='clear'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps aux'
alias psg='ps aux | grep'
alias netstat='netstat -tuln'
alias ports='netstat -tuln'
EOF
fi

section "Service Configuration"
log "Configuring services..."

# Enable SSH if installed
if systemctl list-unit-files | grep -q ssh.service; then
    systemctl enable ssh
    log "SSH service enabled"
fi

# Configure UFW basic rules (but don't enable by default)
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
log "UFW rules configured (not enabled). Enable with: ufw enable"

# Configure fail2ban
if [[ -f /etc/fail2ban/jail.conf ]]; then
    systemctl enable fail2ban
    systemctl start fail2ban
    log "Fail2ban configured and started"
fi

section "Cleanup"
log "Cleaning up package cache..."
apt-get autoremove -y
apt-get autoclean

section "System Information"
log "Displaying system information..."
neofetch

section "Installation Summary"
log "Comprehensive LXC container setup completed!"
log "Installed packages include:"
echo "  - Network utilities (net-tools, nmap, tcpdump, etc.)"
echo "  - Development tools (git, python3, nodejs, golang, etc.)"
echo "  - System monitoring (htop, iotop, sysstat, etc.)"
echo "  - Security tools (fail2ban, ufw, clamav, etc.)"
echo "  - Container support (fuse, systemd-container, etc.)"
echo "  - Database clients (mysql, postgresql, redis, etc.)"
echo "  - Web tools (nginx, certbot, apache2-utils, etc.)"
echo "  - Backup utilities (borgbackup, restic, etc.)"
echo "  - And many more useful tools..."

log "Next steps:"
echo "  1. Configure git: git config --global user.name 'Your Name'"
echo "  2. Configure git: git config --global user.email 'your@email.com'"
echo "  3. Enable firewall: ufw enable (after configuring rules)"
echo "  4. Install Docker when ready"
echo "  5. Reload shell: source ~/.bashrc"

log "Container is ready for use!"