# OpenWebUI Multi-Team Stack - Portable Edition

## 🎯 What's New

This version is **fully portable** and can be deployed to any server with just environment variable changes.

### ✅ Changes Made for Portability

1. **Environment Variables**: All team-specific values use `${TEAM_NAME}` and `${TEAM_DOMAIN_PREFIX}`
2. **Container Names**: Dynamically set based on `TEAM_NAME`
3. **Volume Names**: Automatically prefixed with team name
4. **Fixed Health Checks**: All services now use correct endpoints
5. **Simplified LiteLLM Config**: Removed problematic settings

---

## 📦 Files in This Directory

| File | Description |
|------|-------------|
| `docker-compose.yml` | **Main compose file** - Portable, uses env vars |
| `.env.example` | Environment variable template |
| `litellm-config-FIXED.yaml` | Working LiteLLM configuration |
| `deploy-team.sh` | **Automated deployment script** |
| `DEPLOYMENT-GUIDE.md` | Complete deployment instructions |
| `FIXES-APPLIED.md` | Documentation of all fixes |
| `README-PORTABLE.md` | This file |

---

## 🚀 Quick Start - Deploy to New Server

### Option 1: Automated Script (Recommended)

```bash
# From this directory
./deploy-team.sh team2 10.0.8.41

# The script will:
# 1. Create directories on server
# 2. Upload docker-compose.yml
# 3. Generate unique .env with secrets
# 4. Upload LiteLLM config
# 5. Start all services
# 6. Show health status
```

### Option 2: Manual Deployment

```bash
# 1. Copy files to server
SERVER=10.0.8.41
ssh root@${SERVER} "mkdir -p /root/{litellm,searxng}"
scp docker-compose.yml root@${SERVER}:/root/
scp litellm-config-FIXED.yaml root@${SERVER}:/root/litellm/config.yaml
scp .env.example root@${SERVER}:/root/.env

# 2. Edit .env on server
ssh root@${SERVER}
nano /root/.env
# Change: TEAM_NAME, TEAM_DOMAIN_PREFIX, add API keys, generate secrets

# 3. Start services
cd /root
docker compose up -d
```

---

## 🔧 Configuration

### Required Changes in .env

**For each team, change these:**

```bash
TEAM_NAME=team2                    # team1, team2, team3, team4, team5
TEAM_DOMAIN_PREFIX=team2           # Must match subdomain
```

**Add your API keys:**

```bash
OPENROUTER_API_KEY=sk-or-v1-xxx    # Get from openrouter.ai
```

**Generate unique secrets for each team:**

```bash
# Run these commands to generate:
openssl rand -hex 32              # WEBUI_SECRET_KEY
openssl rand -base64 24           # Passwords
openssl rand -hex 16              # SEARXNG_SECRET
```

---

## 🗺️ Server Mapping

| Team   | IP          | URL |
|--------|-------------|-----|
| team1  | 10.0.8.40   | https://team1-openwebui.valuechainhackers.xyz |
| team2  | 10.0.8.41   | https://team2-openwebui.valuechainhackers.xyz |
| team3  | 10.0.8.42   | https://team3-openwebui.valuechainhackers.xyz |
| team4  | 10.0.8.43   | https://team4-openwebui.valuechainhackers.xyz |
| team5  | 10.0.8.44   | https://team5-openwebui.valuechainhackers.xyz |

---

## ✅ Health Status (Team1 - Reference)

After fixes on team1:
- **13/15 Healthy** (87%)
- **2/15 Stabilizing** (litellm, faster-whisper)
- **0 Failed** 🎉

### Working Services:
✅ OpenWebUI, Postgres, Redis, Ollama, Qdrant, Pipelines, SearXNG, Tika, Jupyter, Neo4j, ClickHouse, MCPO, Watchtower

---

## 🔍 Verification Commands

```bash
# Check service status
docker ps --format 'table {{.Names}}\t{{.Status}}'

# Run health check (if you have the script)
bash checkservices.py ${TEAM_NAME}

# Test OpenWebUI
curl http://localhost:8080/health

# Check logs
docker compose logs -f <service_name>
```

---

## 📋 What Each Service Does

| Service | Purpose | Port |
|---------|---------|------|
| **openwebui** | Main web interface | 8080 |
| **litellm** | Model proxy/router | 4000 |
| **ollama** | Local LLM runtime | 11434 |
| **postgres** | Database | 5432 |
| **qdrant** | Vector database (RAG) | 6333 |
| **jupyter** | Code execution | 8888 |
| **searxng** | Web search | 8081 |
| **tika** | Document extraction | 9998 |
| **faster-whisper** | Speech-to-text | 10300 |
| **neo4j** | Graph database | 7474, 7687 |
| **redis** | Caching | 6379 |
| **clickhouse** | Analytics | 8123 |
| **pipelines** | Plugin framework | 9099 |
| **mcpo** | MCP tools | 8000 |
| **watchtower** | Auto-updates | - |

---

## 🛠️ Common Tasks

### Update Configuration
```bash
# Edit .env
nano /root/.env

# Restart affected services
docker compose up -d --force-recreate <service>
```

### Update LiteLLM Models
```bash
# Edit config
nano /root/litellm/config.yaml

# Restart
docker compose restart litellm
```

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f openwebui

# Last 100 lines
docker logs ${TEAM_NAME}-openwebui --tail 100
```

### Restart Services
```bash
# Restart all
docker compose restart

# Restart one
docker compose restart openwebui

# Recreate (if config changed)
docker compose up -d --force-recreate openwebui
```

---

## 📊 Phase Status

### ✅ Phase 4: Basic Chat - COMPLETE
- All 5 teams can send messages
- OpenRouter integration working
- Multiple chats, history, management working

### 🔄 Phase 5: Storage Backends - READY
- Volume persistence configured
- Qdrant vector DB operational
- Database health checks passing
- File storage ready

### ⏭️ Phase 6: Document Processing - NEXT
- Tika service ready for PDF/DOCX/TXT
- Text extraction configured
- Need to test upload functionality

### ⏭️ Phase 7: RAG - PENDING
- Qdrant ready for embeddings
- Need to configure embedding models
- Citation system to be tested

---

## 🐛 Troubleshooting

### Services Won't Start
```bash
# Check logs
docker compose logs <service>

# Check .env file
cat /root/.env | grep TEAM_NAME

# Recreate from scratch
docker compose down
docker compose up -d
```

### Health Checks Failing
See [FIXES-APPLIED.md](FIXES-APPLIED.md) for solutions to common health check issues.

### LiteLLM Issues
```bash
# Check config syntax
docker exec ${TEAM_NAME}-litellm cat /app/config.yaml

# View logs
docker logs ${TEAM_NAME}-litellm -f

# Use simplified config
cp litellm-config-FIXED.yaml /root/litellm/config.yaml
docker compose restart litellm
```

---

## 📚 Documentation

- **[DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)** - Full deployment instructions
- **[FIXES-APPLIED.md](FIXES-APPLIED.md)** - All health check fixes explained
- **[docker-compose.yml](docker-compose.yml)** - Main configuration file
- **[.env.example](.env.example)** - Environment variable template

---

## 🔐 Security Notes

- Each team should have **unique secrets**
- Never commit `.env` files to git
- Set `.env` permissions to 600: `chmod 600 /root/.env`
- Rotate secrets regularly in production
- Use strong passwords for all services

---

## 🎯 Next Steps

1. **Deploy to remaining teams:**
   ```bash
   ./deploy-team.sh team2 10.0.8.41
   ./deploy-team.sh team3 10.0.8.42
   ./deploy-team.sh team4 10.0.8.43
   ./deploy-team.sh team5 10.0.8.44
   ```

2. **Create admin users** on each team's web interface

3. **Disable signups** after admin created:
   ```bash
   # Edit .env, set: ENABLE_SIGNUP=false
   docker compose up -d openwebui
   ```

4. **Test document upload** (Phase 6)

5. **Configure RAG** and test retrieval (Phase 7)

---

**Status:** ✅ Ready for multi-server deployment
**Last Updated:** 2025-10-03
**Tested On:** team1 @ 10.0.8.40
