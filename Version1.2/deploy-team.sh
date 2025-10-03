#!/bin/bash
# ====================================================
# OpenWebUI Multi-Team Deployment Script
# ====================================================
# Deploys the OpenWebUI stack to a new team server
#
# Usage: ./deploy-team.sh <team_name> <server_ip>
# Example: ./deploy-team.sh team2 10.0.8.41

set -e

TEAM=$1
SERVER_IP=$2

if [ -z "$TEAM" ] || [ -z "$SERVER_IP" ]; then
    echo "❌ Missing arguments"
    echo ""
    echo "Usage: ./deploy-team.sh <team_name> <server_ip>"
    echo ""
    echo "Examples:"
    echo "  ./deploy-team.sh team2 10.0.8.41"
    echo "  ./deploy-team.sh team3 10.0.8.42"
    echo "  ./deploy-team.sh team4 10.0.8.43"
    echo "  ./deploy-team.sh team5 10.0.8.44"
    exit 1
fi

echo "======================================================"
echo "OpenWebUI Multi-Team Deployment"
echo "======================================================"
echo "Team:      $TEAM"
echo "Server:    $SERVER_IP"
echo "Domain:    https://${TEAM}-openwebui.valuechainhackers.xyz"
echo "======================================================"
echo ""

read -p "Continue with deployment? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

echo ""
echo "📁 Step 1: Creating directories on server..."
ssh root@${SERVER_IP} "mkdir -p /root/{litellm,searxng,reports,scripts}"

echo "✅ Directories created"
echo ""

echo "📤 Step 2: Uploading configuration files..."
scp docker-compose.yml root@${SERVER_IP}:/root/
scp litellm-config-FIXED.yaml root@${SERVER_IP}:/root/litellm/config.yaml
echo "✅ Configuration files uploaded"
echo ""

echo "🔐 Step 3: Generating .env file..."
if [ ! -f ".env.example" ]; then
    echo "❌ .env.example not found!"
    exit 1
fi

# Create team-specific .env
cp .env.example .env.${TEAM}

# Update team-specific values
sed -i "s/TEAM_NAME=.*/TEAM_NAME=${TEAM}/" .env.${TEAM}
sed -i "s/TEAM_DOMAIN_PREFIX=.*/TEAM_DOMAIN_PREFIX=${TEAM}/" .env.${TEAM}

# Generate random secrets
WEBUI_SECRET=$(openssl rand -hex 32)
POSTGRES_PASS=$(openssl rand -base64 24 | tr -d "=+/")
QDRANT_KEY=$(openssl rand -base64 24 | tr -d "=+/" | head -c 24)
JUPYTER_TOKEN=$(openssl rand -base64 32 | tr -d "=+/" | head -c 32)
SEARXNG_SECRET=$(openssl rand -hex 16)
NEO4J_PASS=$(openssl rand -base64 16 | tr -d "=+/")
MCPO_KEY=$(openssl rand -base64 24 | tr -d "=+/" | head -c 24)
LITELLM_KEY=$(openssl rand -base64 16 | tr -d "=+/" | head -c 16)

# Replace secrets in .env
sed -i "s/WEBUI_SECRET_KEY=.*/WEBUI_SECRET_KEY=${WEBUI_SECRET}/" .env.${TEAM}
sed -i "s/POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=${POSTGRES_PASS}/" .env.${TEAM}
sed -i "s/QDRANT_API_KEY=.*/QDRANT_API_KEY=qdrant-${QDRANT_KEY}/" .env.${TEAM}
sed -i "s/JUPYTER_TOKEN=.*/JUPYTER_TOKEN=${JUPYTER_TOKEN}/" .env.${TEAM}
sed -i "s/SEARXNG_SECRET=.*/SEARXNG_SECRET=${SEARXNG_SECRET}/" .env.${TEAM}
sed -i "s/NEO4J_PASSWORD=.*/NEO4J_PASSWORD=${NEO4J_PASS}/" .env.${TEAM}
sed -i "s/MCPO_API_KEY=.*/MCPO_API_KEY=mcpo-${MCPO_KEY}/" .env.${TEAM}
sed -i "s/LITELLM_MASTER_KEY=.*/LITELLM_MASTER_KEY=sk-${LITELLM_KEY}/" .env.${TEAM}

echo "✅ Secrets generated"
echo ""

echo "⚠️  IMPORTANT: Add your OpenRouter API key to .env.${TEAM}"
echo "   Edit the file and set: OPENROUTER_API_KEY=sk-or-v1-YOUR-KEY-HERE"
echo ""
read -p "Press Enter after you've added the API key..."

echo ""
echo "📤 Step 4: Uploading .env file..."
scp .env.${TEAM} root@${SERVER_IP}:/root/.env
ssh root@${SERVER_IP} "chmod 600 /root/.env"
echo "✅ .env uploaded with secure permissions"
echo ""

echo "🚀 Step 5: Starting services..."
ssh root@${SERVER_IP} "cd /root && docker compose up -d"
echo "✅ Services started"
echo ""

echo "⏳ Waiting 15 seconds for services to initialize..."
sleep 15
echo ""

echo "🔍 Step 6: Checking service health..."
ssh root@${SERVER_IP} "docker ps --format 'table {{.Names}}\t{{.Status}}' | grep ${TEAM}"
echo ""

echo "======================================================"
echo "✅ Deployment Complete!"
echo "======================================================"
echo ""
echo "🌐 Web Interface: https://${TEAM}-openwebui.valuechainhackers.xyz"
echo "🔐 First Login: Sign up to create admin account"
echo ""
echo "📊 Health Check:"
echo "   ssh root@${SERVER_IP} 'bash checkservices.py ${TEAM}'"
echo ""
echo "📝 Logs:"
echo "   ssh root@${SERVER_IP} 'docker compose logs -f <service>'"
echo ""
echo "🔧 Manage:"
echo "   ssh root@${SERVER_IP}"
echo "   cd /root"
echo "   docker compose up -d    # Start all"
echo "   docker compose down     # Stop all"
echo "   docker compose restart <service>  # Restart one"
echo ""
echo "💾 Local .env backup: .env.${TEAM}"
echo "======================================================"
