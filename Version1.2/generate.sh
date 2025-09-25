#!/bin/bash
set -e

echo "=== Team1 OpenWebUI .env Generator ==="

# Check if .env already exists
if [[ -f .env ]]; then
    echo "WARNING: .env file already exists!"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting. Existing .env file preserved."
        exit 0
    fi
    cp .env .env.backup
    echo "Existing .env backed up to .env.backup"
fi

# Function to generate random hex string
generate_hex() {
    local length=${1:-32}
    openssl rand -hex $length
}

# Function to generate random base64 string  
generate_base64() {
    local length=${1:-32}
    openssl rand -base64 $length | tr -d "=+/" | cut -c1-$length
}

# Function to generate API key format
generate_api_key() {
    local prefix=${1:-"sk"}
    local length=${2:-32}
    echo "${prefix}-$(generate_base64 $length)"
}

echo "Generating secure random keys..."

# Generate all the random values
WEBUI_SECRET_KEY=$(generate_hex 32)
POSTGRES_PASSWORD=$(generate_base64 24)
LANGFUSE_DB_PASSWORD=$(generate_base64 24)
OPENROUTER_API_KEY="sk-or-v1-team1-your-openrouter-key-here"
PIPELINES_API_KEY="0p3n-w3bu!"
MCPO_API_KEY=$(generate_api_key "mcpo" 24)
QDRANT_API_KEY=$(generate_api_key "qdrant" 24)
JUPYTER_TOKEN=$(generate_base64 32)
SEARXNG_SECRET=$(generate_hex 16)
NEO4J_PASSWORD=$(generate_base64 16)
LANGFUSE_PUBLIC_KEY=$(generate_api_key "pk-lf" 24)
LANGFUSE_SECRET_KEY=$(generate_api_key "sk-lf" 24)
NEXTAUTH_SECRET=$(generate_hex 32)
LANGFUSE_SALT=$(generate_base64 16)
LITELLM_MASTER_KEY=$(generate_api_key "sk" 16)

# Create the .env file
cat > .env << EOF
# ==============================================
# TEAM1 OPENWEBUI ENVIRONMENT CONFIGURATION
# ==============================================
# Generated on: $(date)
# WARNING: Keep this file secure and never commit to version control!

# ===================
# CORE OPENWEBUI
# ===================
WEBUI_SECRET_KEY=${WEBUI_SECRET_KEY}
WEBUI_URL=https://team1-openwebui.valuechainhackers.xyz

# ===================
# DATABASE CONFIGURATION
# ===================
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
LANGFUSE_DB_PASSWORD=${LANGFUSE_DB_PASSWORD}

# ===================
# EXTERNAL AI APIS (OpenRouter)
# ===================
# IMPORTANT: Replace this with your actual OpenRouter API key!
OPENROUTER_API_KEY=${OPENROUTER_API_KEY}

# ===================
# PIPELINES & TOOLS
# ===================
PIPELINES_API_KEY=${PIPELINES_API_KEY}
MCPO_API_KEY=${MCPO_API_KEY}

# ===================
# VECTOR DATABASE
# ===================
QDRANT_API_KEY=${QDRANT_API_KEY}

# ===================
# CODE EXECUTION
# ===================
JUPYTER_TOKEN=${JUPYTER_TOKEN}

# ===================
# SEARCH ENGINE
# ===================
SEARXNG_SECRET=${SEARXNG_SECRET}

# ===================
# GRAPH DATABASE
# ===================
NEO4J_PASSWORD=${NEO4J_PASSWORD}

# ===================
# OBSERVABILITY (Langfuse)
# ===================
LANGFUSE_PUBLIC_KEY=${LANGFUSE_PUBLIC_KEY}
LANGFUSE_SECRET_KEY=${LANGFUSE_SECRET_KEY}
NEXTAUTH_SECRET=${NEXTAUTH_SECRET}
LANGFUSE_SALT=${LANGFUSE_SALT}

# ===================
# LITELLM PROXY
# ===================
LITELLM_MASTER_KEY=${LITELLM_MASTER_KEY}

# ===================
# OPTIONAL: EXTERNAL INTEGRATIONS
# ===================

# Google Drive Integration (optional)
# GOOGLE_DRIVE_CLIENT_ID=your-google-client-id
# GOOGLE_DRIVE_API_KEY=your-google-api-key

# Microsoft OneDrive Integration (optional)
# ONEDRIVE_CLIENT_ID=your-onedrive-client-id
# ONEDRIVE_PERSONAL_CLIENT_ID=your-personal-onedrive-client-id

# Additional AI API Keys (optional)
# ANTHROPIC_API_KEY=sk-ant-your-anthropic-key
# COHERE_API_KEY=your-cohere-api-key
# PERPLEXITY_API_KEY=pplx-your-perplexity-key

# ===================
# TEAM IDENTIFICATION
# ===================
TEAM_NAME=team1
TEAM_DOMAIN_PREFIX=team1
EOF

# Set proper permissions
chmod 600 .env

echo ""
echo "=== .env File Generated Successfully ==="
echo ""
echo "✅ Generated secure random keys for all services"
echo "⚠️  IMPORTANT: You still need to:"
echo "   1. Replace OPENROUTER_API_KEY with your actual OpenRouter API key"
echo "   2. Add any optional API keys you want to use"
echo ""
echo "🔒 File permissions set to 600 (owner read/write only)"
echo "📁 Location: $(pwd)/.env"
echo ""
echo "🚨 SECURITY REMINDER:"
echo "   - Never commit this .env file to version control"
echo "   - Keep it secure and backed up safely"
echo "   - Rotate keys regularly in production"
echo ""

# Display summary of generated keys (lengths only for security)
echo "=== Generated Key Summary ==="
echo "WEBUI_SECRET_KEY: ${#WEBUI_SECRET_KEY} characters"
echo "POSTGRES_PASSWORD: ${#POSTGRES_PASSWORD} characters" 
echo "LANGFUSE_DB_PASSWORD: ${#LANGFUSE_DB_PASSWORD} characters"
echo "MCPO_API_KEY: ${#MCPO_API_KEY} characters"
echo "QDRANT_API_KEY: ${#QDRANT_API_KEY} characters"
echo "JUPYTER_TOKEN: ${#JUPYTER_TOKEN} characters"
echo "SEARXNG_SECRET: ${#SEARXNG_SECRET} characters"
echo "NEO4J_PASSWORD: ${#NEO4J_PASSWORD} characters"
echo "LANGFUSE_PUBLIC_KEY: ${#LANGFUSE_PUBLIC_KEY} characters"
echo "LANGFUSE_SECRET_KEY: ${#LANGFUSE_SECRET_KEY} characters"
echo "NEXTAUTH_SECRET: ${#NEXTAUTH_SECRET} characters"
echo "LANGFUSE_SALT: ${#LANGFUSE_SALT} characters"
echo "LITELLM_MASTER_KEY: ${#LITELLM_MASTER_KEY} characters"
echo ""
echo "Ready to deploy! 🚀"