#!/bin/bash
set -euo pipefail

GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
fail() { echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }

trap 'fail "An unexpected error occurred. Exiting."' ERR

log "🔄 Updating base system packages..."
apt-get update -y
apt-get upgrade -y

log "📦 Installing core dependencies (no Docker)..."
apt-get install -y \
  curl \
  wget \
  gnupg \
  lsb-release \
  ca-certificates \
  net-tools \
  iptables \
  software-properties-common \
  unzip \
  htop \
  bash-completion \
  tmux \
  nano \
  neofetch \
  acl \
  git

log "✅ Base system is ready (minus Docker)."
