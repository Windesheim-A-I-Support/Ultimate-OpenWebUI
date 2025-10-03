# Multi-Server Deployment Guide

## Overview
This guide shows how to deploy the OpenWebUI stack to multiple servers (team1-team5).

## Prerequisites
- Docker & Docker Compose installed on each server
- SSH access to each server
- Domain DNS configured (team1-openwebui.valuechainhackers.xyz, etc.)

---

## Quick Deploy to New Server

### 1. Copy Files to New Server
```bash
# From your local machine
TEAM=team2  # Change this: team2, team3, team4, team5
SERVER_IP=10.0.8.41  # Change this: .41, .42, .43, .44

# Create directory on server
ssh root@${SERVER_IP} "mkdir -p /root/{litellm,searxng}"

# Copy files
scp docker-compose.yml root@${SERVER_IP}:/root/
scp .env.example root@${SERVER_IP}:/root/.env
scp litellm-config-FIXED.yaml root@${SERVER_IP}:/root/litellm/config.yaml
```

### 2. Configure Environment Variables
```bash
# SSH into the server
ssh root@${SERVER_IP}

# Edit .env file
nano .env
```

**Update these values in .env:**
```bash
# Change TEAM_NAME and TEAM_DOMAIN_PREFIX
TEAM_NAME=team2                    # <- CHANGE THIS
TEAM_DOMAIN_PREFIX=team2           # <- CHANGE THIS

# Generate new secrets (run these commands):
openssl rand -hex 32  # For WEBUI_SECRET_KEY
openssl rand -base64 24  # For passwords
openssl rand -hex 16  # For SEARXNG_SECRET

# Add your OpenRouter API key
OPENROUTER_API_KEY=sk-or-v1-YOUR-KEY-HERE  # <- ADD YOUR KEY
```

### 3. Start Services
```bash
cd /root
docker compose up -d
```

### 4. Verify Deployment
```bash
# Check services
docker ps

# Run health check (if you have the script)
bash checkservices.py ${TEAM_NAME}

# Check OpenWebUI is accessible
curl http://localhost:8080/health
```

### 5. Access Web Interface
Open browser to: `https://team2-openwebui.valuechainhackers.xyz` (replace team2 with your team)

---

## Server Mapping

| Team   | Server IP   | Domain                                        |
|--------|-------------|-----------------------------------------------|
| team1  | 10.0.8.40   | https://team1-openwebui.valuechainhackers.xyz |
| team2  | 10.0.8.41   | https://team2-openwebui.valuechainhackers.xyz |
| team3  | 10.0.8.42   | https://team3-openwebui.valuechainhackers.xyz |
| team4  | 10.0.8.43   | https://team4-openwebui.valuechainhackers.xyz |
| team5  | 10.0.8.44   | https://team5-openwebui.valuechainhackers.xyz |

---

## Environment Variables Required

### Core (Required)
```bash
TEAM_NAME=team1                     # Container prefix and volume names
TEAM_DOMAIN_PREFIX=team1            # Subdomain prefix
WEBUI_SECRET_KEY=<64-char-hex>      # Session encryption key
POSTGRES_PASSWORD=<secure-password>  # Database password
OPENROUTER_API_KEY=sk-or-v1-xxx     # OpenRouter API key
```

### Services (Required)
```bash
QDRANT_API_KEY=qdrant-xxx           # Vector DB API key
JUPYTER_TOKEN=<secure-token>        # Jupyter notebook token
SEARXNG_SECRET=<32-char-hex>        # SearXNG secret key
NEO4J_PASSWORD=<secure-password>    # Neo4j database password
MCPO_API_KEY=mcpo-xxx               # MCP tools API key
LITELLM_MASTER_KEY=sk-xxx           # LiteLLM master key
```

### Optional (for Langfuse observability)
```bash
LANGFUSE_PUBLIC_KEY=pk-lf-xxx
LANGFUSE_SECRET_KEY=sk-lf-xxx
LANGFUSE_DB_PASSWORD=<secure-password>
NEXTAUTH_SECRET=<64-char-hex>
LANGFUSE_SALT=<secure-string>
```

---

## File Structure on Server

```
/root/
├── docker-compose.yml          # Main compose file (portable)
├── .env                        # Team-specific configuration
├── litellm/
│   └── config.yaml            # LiteLLM model configuration
├── searxng/                   # SearXNG config (auto-generated)
└── checkservices.py           # Health check script (optional)
```

---

## Deployment Script (Automated)

Create this script locally to deploy to multiple servers:

```bash
#!/bin/bash
# deploy-team.sh

TEAM=$1
SERVER_IP=$2

if [ -z "$TEAM" ] || [ -z "$SERVER_IP" ]; then
    echo "Usage: ./deploy-team.sh <team_name> <server_ip>"
    echo "Example: ./deploy-team.sh team2 10.0.8.41"
    exit 1
fi

echo "Deploying $TEAM to $SERVER_IP..."

# Create directories
ssh root@${SERVER_IP} "mkdir -p /root/{litellm,searxng,reports}"

# Copy files
scp docker-compose.yml root@${SERVER_IP}:/root/
scp litellm-config-FIXED.yaml root@${SERVER_IP}:/root/litellm/config.yaml

# Generate .env from template
cp .env.example .env.${TEAM}
sed -i "s/TEAM_NAME=.*/TEAM_NAME=${TEAM}/" .env.${TEAM}
sed -i "s/TEAM_DOMAIN_PREFIX=.*/TEAM_DOMAIN_PREFIX=${TEAM}/" .env.${TEAM}

# Upload .env
scp .env.${TEAM} root@${SERVER_IP}:/root/.env

echo "Files uploaded. Now SSH into server and:"
echo "  1. Edit /root/.env - add API keys and generate secrets"
echo "  2. Run: cd /root && docker compose up -d"
echo ""
echo "SSH command: ssh root@${SERVER_IP}"
```

**Usage:**
```bash
chmod +x deploy-team.sh
./deploy-team.sh team2 10.0.8.41
./deploy-team.sh team3 10.0.8.42
./deploy-team.sh team4 10.0.8.43
./deploy-team.sh team5 10.0.8.44
```

---

## Updating Existing Deployment

### Update docker-compose.yml
```bash
# On server
cd /root
docker compose down
# Upload new docker-compose.yml
docker compose up -d
```

### Update Single Service
```bash
docker compose up -d --force-recreate <service_name>
# Example:
docker compose up -d --force-recreate openwebui
```

### Update LiteLLM Config
```bash
# Edit config
nano /root/litellm/config.yaml

# Restart LiteLLM
docker compose restart litellm
```

---

## Troubleshooting

### Services Not Starting
```bash
# Check logs
docker compose logs <service_name>

# Check all unhealthy services
docker ps --filter "health=unhealthy"
```

### Health Checks Failing
```bash
# Run health check script
bash checkservices.py ${TEAM_NAME}

# Manual checks
docker exec ${TEAM_NAME}-openwebui curl http://localhost:8080/health
docker exec ${TEAM_NAME}-qdrant timeout 2 bash -c 'cat < /dev/null > /dev/tcp/localhost/6333'
```

### LiteLLM Issues
```bash
# Check config is valid YAML
docker exec ${TEAM_NAME}-litellm cat /app/config.yaml

# Check logs
docker logs ${TEAM_NAME}-litellm --tail 50

# Recreate container
docker compose up -d --force-recreate litellm
```

### Port Conflicts
If deploying multiple teams on one server, change ports in docker-compose.yml:
```yaml
ports:
  - "8080:8080"  # Change to 8081, 8082, etc.
```

---

## Security Checklist

- [ ] Generated unique secrets for each team
- [ ] Changed default passwords
- [ ] Restricted SSH access
- [ ] Configured firewall rules
- [ ] SSL certificates configured in Traefik
- [ ] Regular backups scheduled
- [ ] `.env` file has 600 permissions (`chmod 600 .env`)

---

## Backup & Restore

### Backup Volumes
```bash
# Backup all volumes
docker run --rm \
  -v ${TEAM_NAME}-openwebui-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/${TEAM_NAME}-backup-$(date +%Y%m%d).tar.gz /data

# Backup database
docker exec ${TEAM_NAME}-postgres pg_dump -U openwebui openwebui > backup-$(date +%Y%m%d).sql
```

### Restore Volumes
```bash
# Restore volume
docker run --rm \
  -v ${TEAM_NAME}-openwebui-data:/data \
  -v $(pwd):/backup \
  alpine sh -c "cd /data && tar xzf /backup/${TEAM_NAME}-backup-YYYYMMDD.tar.gz --strip 1"

# Restore database
cat backup-YYYYMMDD.sql | docker exec -i ${TEAM_NAME}-postgres psql -U openwebui
```

---

## Next Steps

After deployment:

1. **Create Admin User**: Visit the web interface and sign up
2. **Disable Signups**: Set `ENABLE_SIGNUP=false` in `.env` and restart
3. **Configure Models**: Add models in OpenWebUI admin panel
4. **Test RAG**: Upload a document and test retrieval
5. **Configure Traefik**: Add routing rules for your team subdomain

---

## Support

- Health reports: `bash checkservices.py <team_name>`
- Logs: `docker compose logs -f <service>`
- Status: `docker ps`
- Documentation: See README.md and FIXES-APPLIED.md
