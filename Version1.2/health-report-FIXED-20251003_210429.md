# OpenWebUI Services Health Report

**Generated:** 2025-10-03 19:04:07 UTC
**Team(s):** team1
**Server:** Production-OpenWebTeam1
**Container Discovery:** ID-based (supports multiple teams)

---

## Executive Summary


| Status | Count | Percentage |
|--------|-------|------------|
| 🔴 Failed/Exited | 1 | 6.2% |
| 🟡 Unhealthy | 1 | 6.2% |
| 🟢 Healthy | 14 | 87.5% |
| **Total** | **16** | **100%** |

---

## Service Status Overview


| Service | Team | Container Name | Container ID | Status | Health Check |
|---------|------|----------------|--------------|--------|--------------|
| 🟢 **clickhouse** | team1 | `team1-clickhouse` | `3024b0722dee` | Up 27 hours (healthy) | healthy |
| 🟢 **faster-whisper** | team1 | `team1-faster-whisper` | `e9b793517b3c` | Up 6 minutes (health: starting) | starting |
| 🟢 **jupyter** | team1 | `team1-jupyter` | `396624ce2a92` | Up 27 hours (healthy) | healthy |
| 🟡 **litellm** | team1 | `team1-litellm` | `93494c64171c` | Up 5 minutes (unhealthy) | unhealthy |
| 🟢 **mcpo** | team1 | `team1-mcpo` | `df67d84c81db` | Up 27 hours (healthy) | healthy |
| 🟢 **neo4j** | team1 | `team1-neo4j` | `6d542e21d5d3` | Up 27 hours (healthy) | healthy |
| 🟢 **ollama** | team1 | `team1-ollama` | `09161c5e4098` | Up 27 hours (healthy) | healthy |
| 🔴 **ollama-puller** | team1 | `team1-ollama-puller` | `df8a304dad11` | Exited (0) 27 hours ago | no-healthcheck |
| 🟢 **openwebui** | team1 | `team1-openwebui` | `0854e295e972` | Up 27 hours (healthy) | healthy |
| 🟢 **pipelines** | team1 | `team1-pipelines` | `d7ae4dd3173e` | Up 6 minutes (healthy) | healthy |
| 🟢 **postgres** | team1 | `team1-postgres` | `3d70fef4fe6f` | Up 27 hours (healthy) | healthy |
| 🟢 **qdrant** | team1 | `team1-qdrant` | `3cd84617c215` | Up 3 minutes (healthy) | healthy |
| 🟢 **redis** | team1 | `team1-redis` | `dddea37a29ca` | Up 27 hours (healthy) | healthy |
| 🟢 **searxng** | team1 | `team1-searxng` | `8eb1a406d930` | Up 6 minutes (healthy) | healthy |
| 🟢 **tika** | team1 | `team1-tika` | `2c28c3c5d385` | Up 3 minutes (healthy) | healthy |
| 🟢 **watchtower** | team1 | `team1-watchtower` | `0aadf340faa9` | Up 27 hours (healthy) | healthy |

---

## Detailed Service Analysis


### 🔴 Failed Services (Critical)


#### team1 - ollama-puller

**Container:** `team1-ollama-puller`  
**Container ID:** `df8a304dad11`  
**Team:** team1  
**Service:** ollama-puller  
**Status:** Exited (0) 27 hours ago  

<details>
<summary>📋 Last 50 log lines</summary>

```
Pulling essential models...
Essential models pulled successfully
```

</details>


### 🟡 Unhealthy Services (Running but failing health checks)


#### team1 - litellm

**Container:** `team1-litellm`  
**Container ID:** `93494c64171c`  
**Team:** team1  
**Service:** litellm  
**Health Status:** unhealthy  

<details>
<summary>📋 Last 50 log lines</summary>

```

   ██╗     ██╗████████╗███████╗██╗     ██╗     ███╗   ███╗
   ██║     ██║╚══██╔══╝██╔════╝██║     ██║     ████╗ ████║
   ██║     ██║   ██║   █████╗  ██║     ██║     ██╔████╔██║
   ██║     ██║   ██║   ██╔══╝  ██║     ██║     ██║╚██╔╝██║
   ███████╗██║   ██║   ███████╗███████╗███████╗██║ ╚═╝ ██║
   ╚══════╝╚═╝   ╚═╝   ╚══════╝╚══════╝╚══════╝╚═╝     ╚═╝

```

</details>


### 🟢 Healthy Services

The following services are running and healthy:

- ✅ **team1 - clickhouse** (`team1-clickhouse`) - Up 27 hours (healthy)
- ✅ **team1 - faster-whisper** (`team1-faster-whisper`) - Up 6 minutes (health: starting)
- ✅ **team1 - jupyter** (`team1-jupyter`) - Up 27 hours (healthy)
- ✅ **team1 - mcpo** (`team1-mcpo`) - Up 27 hours (healthy)
- ✅ **team1 - neo4j** (`team1-neo4j`) - Up 27 hours (healthy)
- ✅ **team1 - ollama** (`team1-ollama`) - Up 27 hours (healthy)
- ✅ **team1 - openwebui** (`team1-openwebui`) - Up 27 hours (healthy)
- ✅ **team1 - pipelines** (`team1-pipelines`) - Up 7 minutes (healthy)
- ✅ **team1 - postgres** (`team1-postgres`) - Up 27 hours (healthy)
- ✅ **team1 - qdrant** (`team1-qdrant`) - Up 3 minutes (healthy)
- ✅ **team1 - redis** (`team1-redis`) - Up 27 hours (healthy)
- ✅ **team1 - searxng** (`team1-searxng`) - Up 7 minutes (healthy)
- ✅ **team1 - tika** (`team1-tika`) - Up 3 minutes (healthy)
- ✅ **team1 - watchtower** (`team1-watchtower`) - Up 27 hours (healthy)

---

## System Information

**Docker Version:**
```
Docker version 28.4.0, build d8eb465
```

**Docker Compose Version:**
```
Docker Compose version v2.39.4
```

**System Resources:**
```
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          16        15        23.61GB   523.7MB (2%)
Containers      16        15        494.9MB   0B (0%)
Local Volumes   22        14        6.666GB   0B (0%)
Build Cache     0         0         0B        0B
```

**Network Status:**
```
## Team: team1
No networks found


```

**Volume Status:**
```
## Team: team1
local     team1-clickhouse-data
local     team1-faster-whisper-data
local     team1-jupyter-data
local     team1-neo4j-data
local     team1-neo4j-import
local     team1-neo4j-logs
local     team1-neo4j-plugins
local     team1-ollama-data
local     team1-openwebui-data
local     team1-pipelines-data
local     team1-postgres-data
local     team1-qdrant-data
local     team1-redis-data


```

---

## Recommendations


### Critical Actions Required:

1. ⚠️ **1 service(s) have failed** - Review logs above and restart/fix configuration
2. Check the detailed logs in the 'Failed Services' section
3. Verify environment variables are set correctly in `.env` file

### Health Check Failures:

1. ⚠️ **1 service(s) are unhealthy** - Services running but health checks failing
2. Review logs for each unhealthy service
3. Verify service dependencies are running
4. Check if ports are accessible and not blocked

---

*Report generated by OpenWebUI Health Check Script v2.0 (Multi-Team Edition)*
