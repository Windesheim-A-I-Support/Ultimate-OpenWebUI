#!/bin/bash
# ==============================================
# OpenWebUI Team Services Health Check Script
# ==============================================
# Generates a detailed markdown report of all service statuses and logs

# Configuration
TEAM_PREFIX="team1"
LOG_LINES=100
REPORT_DIR="./reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="${REPORT_DIR}/health-report_${TIMESTAMP}.md"

# Service lists
ALL_SERVICES=(
    "litellm"
    "tika"
    "searxng"
    "qdrant"
    "pipelines"
    "faster-whisper"
    "openwebui"
    "ollama"
    "postgres"
    "redis"
    "neo4j"
    "jupyter"
    "mcpo"
    "clickhouse"
    "watchtower"
)

# Colors for terminal output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create reports directory
mkdir -p "$REPORT_DIR"

echo "========================================"
echo "OpenWebUI Health Check Script v2.0"
echo "========================================"
echo ""

# Start generating report
echo "Generating health report for ${TEAM_PREFIX}..."

# Initialize report
cat > "$REPORT_FILE" << EOF
# OpenWebUI Services Health Report

**Generated:** $(date +"%Y-%m-%d %H:%M:%S %Z")
**Team:** ${TEAM_PREFIX}
**Server:** $(hostname)
**User:** $(whoami)

---

## Executive Summary

EOF

# ============================================
# SYSTEM ENVIRONMENT CHECKS
# ============================================
echo "Checking system environment..."

cat >> "$REPORT_FILE" << 'EOF'

## System Environment

### Operating System
```
EOF

cat >> "$REPORT_FILE" << EOF
$(uname -a)
$(cat /etc/os-release 2>/dev/null || echo "OS info not available")
EOF

cat >> "$REPORT_FILE" << 'EOF'
```

### System Resources
```
EOF

cat >> "$REPORT_FILE" << EOF
Memory:
$(free -h)

Disk:
$(df -h / /var/lib/docker 2>/dev/null || df -h /)

CPU:
$(lscpu | grep -E 'Model name|CPU\(s\)|Thread|Core' || echo "CPU info not available")
EOF

cat >> "$REPORT_FILE" << 'EOF'
```

### Docker Installation
```
EOF

cat >> "$REPORT_FILE" << EOF
Docker Version: $(docker --version 2>&1)
Docker Compose: $(docker compose version 2>/dev/null || docker-compose --version 2>/dev/null || echo "Not found")

Docker Info:
$(docker info 2>&1 | grep -E 'Server Version|Storage Driver|Logging Driver|Cgroup|Kernel|Operating System|CPUs|Total Memory|Docker Root Dir' || echo "Docker info unavailable")
EOF

cat >> "$REPORT_FILE" << 'EOF'
```

### Network Configuration
```
EOF

cat >> "$REPORT_FILE" << EOF
Network Interfaces:
$(ip -4 addr show 2>/dev/null || ifconfig 2>/dev/null || echo "Network info not available")

Active Connections:
$(ss -tulpn 2>/dev/null | head -20 || netstat -tulpn 2>/dev/null | head -20 || echo "Connection info not available")
EOF

cat >> "$REPORT_FILE" << 'EOF'
```

### Docker Networks
```
EOF

docker network ls >> "$REPORT_FILE" 2>&1

cat >> "$REPORT_FILE" << 'EOF'
```

### Docker Volumes
```
EOF

docker volume ls >> "$REPORT_FILE" 2>&1

cat >> "$REPORT_FILE" << 'EOF'
```

### Running Containers (All)
```
EOF

docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" >> "$REPORT_FILE" 2>&1

cat >> "$REPORT_FILE" << 'EOF'
```

### Docker Resource Usage
```
EOF

docker system df -v 2>&1 | head -50 >> "$REPORT_FILE"

cat >> "$REPORT_FILE" << 'EOF'
```

### Environment Files Check
```
EOF

cat >> "$REPORT_FILE" << EOF
Checking for .env file:
$([[ -f ".env" ]] && echo "✅ .env file exists" || echo "❌ .env file NOT FOUND")
$([[ -f ".env" ]] && echo "Size: $(stat -f%z .env 2>/dev/null || stat -c%s .env 2>/dev/null) bytes" || echo "")

Checking for docker-compose file:
$([[ -f "docker-compose.yml" ]] && echo "✅ docker-compose.yml exists" || echo "")
$([[ -f "docker-compose ultimate copy.yml" ]] && echo "✅ docker-compose ultimate copy.yml exists" || echo "")
$([[ ! -f "docker-compose.yml" && ! -f "docker-compose ultimate copy.yml" ]] && echo "❌ No docker-compose file found" || echo "")

Current directory: $(pwd)
Directory contents:
$(ls -lah | head -30)
EOF

cat >> "$REPORT_FILE" << 'EOF'
```

---

## Service Status Analysis

EOF

# ============================================
# SERVICE STATUS CHECKS
# ============================================

# Count statuses
FAILED_COUNT=0
UNHEALTHY_COUNT=0
HEALTHY_COUNT=0
TOTAL_COUNT=${#ALL_SERVICES[@]}

echo "Analyzing ${TOTAL_COUNT} services..."

# Create temporary file for service data
TEMP_FILE=$(mktemp)

for service in "${ALL_SERVICES[@]}"; do
    container_name="${TEAM_PREFIX}-${service}"
    echo "  Checking: ${container_name}..."

    # Get container status (with timeout)
    status=$(timeout 5 docker ps -a --filter "name=^${container_name}$" --format "{{.Status}}" 2>/dev/null || echo "NOT FOUND")

    # Get detailed container info
    created=$(timeout 5 docker ps -a --filter "name=^${container_name}$" --format "{{.CreatedAt}}" 2>/dev/null || echo "Unknown")
    ports=$(timeout 5 docker ps -a --filter "name=^${container_name}$" --format "{{.Ports}}" 2>/dev/null || echo "N/A")

    # Get health status (with timeout)
    health="no-healthcheck"
    if [[ "$status" != "NOT FOUND" ]] && [[ -n "$status" ]]; then
        health=$(timeout 5 docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}no-healthcheck{{end}}' "$container_name" 2>/dev/null || echo "no-healthcheck")
    fi

    # Determine icon and count
    if [[ "$status" == "NOT FOUND" ]] || [[ -z "$status" ]]; then
        icon="🔴"
        status="NOT FOUND"
        ((FAILED_COUNT++))
    elif [[ "$status" == *"Exited"* ]]; then
        icon="🔴"
        ((FAILED_COUNT++))
    elif [[ "$health" == "unhealthy" ]]; then
        icon="🟡"
        ((UNHEALTHY_COUNT++))
    elif [[ "$status" == *"Up"* ]]; then
        icon="🟢"
        ((HEALTHY_COUNT++))
    else
        icon="⚪"
    fi

    # Store data
    echo "${icon}|${service}|${container_name}|${status}|${health}|${created}|${ports}" >> "$TEMP_FILE"

    # Terminal output
    if [[ "$icon" == "🔴" ]]; then
        echo -e "${RED}  ✗ ${container_name}: ${status}${NC}"
    elif [[ "$icon" == "🟡" ]]; then
        echo -e "${YELLOW}  ⚠ ${container_name}: ${status} (unhealthy)${NC}"
    elif [[ "$icon" == "🟢" ]]; then
        echo -e "${GREEN}  ✓ ${container_name}: OK${NC}"
    fi
done

echo "Analysis complete."
echo ""

# Add summary table
cat >> "$REPORT_FILE" << EOF

### Summary

| Status | Count | Percentage |
|--------|-------|------------|
| 🔴 Failed/Exited | ${FAILED_COUNT} | $(awk "BEGIN {printf \"%.1f\", (${FAILED_COUNT}/${TOTAL_COUNT})*100}")% |
| 🟡 Unhealthy | ${UNHEALTHY_COUNT} | $(awk "BEGIN {printf \"%.1f\", (${UNHEALTHY_COUNT}/${TOTAL_COUNT})*100}")% |
| 🟢 Healthy | ${HEALTHY_COUNT} | $(awk "BEGIN {printf \"%.1f\", (${HEALTHY_COUNT}/${TOTAL_COUNT})*100}")% |
| **Total** | **${TOTAL_COUNT}** | **100%** |

### Service Status Overview

| Service | Container Name | Status | Health | Created | Ports |
|---------|---------------|---------|---------|---------|-------|
EOF

# Add service table rows
while IFS='|' read -r icon service container_name status health created ports; do
    echo "| $icon **$service** | \`$container_name\` | $status | $health | $created | $ports |" >> "$REPORT_FILE"
done < "$TEMP_FILE"

# ============================================
# DETAILED ANALYSIS
# ============================================

cat >> "$REPORT_FILE" << 'EOF'

---

## Detailed Service Analysis

### 🔴 Failed Services (Critical)

EOF

echo "Collecting logs for failed services..."

# Failed services logs
FAILED_FOUND=false
while IFS='|' read -r icon service container_name status health created ports; do
    if [[ "$icon" == "🔴" ]]; then
        FAILED_FOUND=true

        echo "" >> "$REPORT_FILE"
        echo "#### ${service}" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        echo "**Container:** \`${container_name}\`  " >> "$REPORT_FILE"
        echo "**Status:** ${status}  " >> "$REPORT_FILE"
        echo "**Created:** ${created}  " >> "$REPORT_FILE"
        echo "**Ports:** ${ports}  " >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"

        if [[ "$status" != "NOT FOUND" ]]; then
            # Get container details
            echo "<details>" >> "$REPORT_FILE"
            echo "<summary>🔍 Container Inspection</summary>" >> "$REPORT_FILE"
            echo "" >> "$REPORT_FILE"
            echo '```json' >> "$REPORT_FILE"
            timeout 10 docker inspect "$container_name" 2>&1 | head -200 >> "$REPORT_FILE" || echo "Failed to inspect" >> "$REPORT_FILE"
            echo '```' >> "$REPORT_FILE"
            echo "" >> "$REPORT_FILE"
            echo "</details>" >> "$REPORT_FILE"
            echo "" >> "$REPORT_FILE"

            # Get logs
            echo "<details>" >> "$REPORT_FILE"
            echo "<summary>📋 Last ${LOG_LINES} log lines</summary>" >> "$REPORT_FILE"
            echo "" >> "$REPORT_FILE"
            echo '```' >> "$REPORT_FILE"
            timeout 15 docker logs "${container_name}" --tail ${LOG_LINES} 2>&1 >> "$REPORT_FILE" || echo "Failed to retrieve logs" >> "$REPORT_FILE"
            echo '```' >> "$REPORT_FILE"
            echo "" >> "$REPORT_FILE"
            echo "</details>" >> "$REPORT_FILE"
        fi
        echo "" >> "$REPORT_FILE"

        echo "  → Collected logs for ${container_name}"
    fi
done < "$TEMP_FILE"

if [[ "$FAILED_FOUND" == "false" ]]; then
    echo "✅ No failed services detected." >> "$REPORT_FILE"
    echo "  No failed services found."
fi

# Unhealthy services
cat >> "$REPORT_FILE" << 'EOF'

### 🟡 Unhealthy Services (Running but failing health checks)

EOF

echo "Collecting logs for unhealthy services..."

UNHEALTHY_FOUND=false
while IFS='|' read -r icon service container_name status health created ports; do
    if [[ "$icon" == "🟡" ]]; then
        UNHEALTHY_FOUND=true

        echo "" >> "$REPORT_FILE"
        echo "#### ${service}" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        echo "**Container:** \`${container_name}\`  " >> "$REPORT_FILE"
        echo "**Status:** ${status}  " >> "$REPORT_FILE"
        echo "**Health:** ${health}  " >> "$REPORT_FILE"
        echo "**Created:** ${created}  " >> "$REPORT_FILE"
        echo "**Ports:** ${ports}  " >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"

        # Get healthcheck details
        echo "<details>" >> "$REPORT_FILE"
        echo "<summary>🏥 Health Check Details</summary>" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        echo '```json' >> "$REPORT_FILE"
        timeout 10 docker inspect --format='{{json .State.Health}}' "$container_name" 2>&1 | python3 -m json.tool 2>/dev/null >> "$REPORT_FILE" || \
        docker inspect --format='{{json .State.Health}}' "$container_name" 2>&1 >> "$REPORT_FILE" || echo "No health data" >> "$REPORT_FILE"
        echo '```' >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        echo "</details>" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"

        # Get logs
        echo "<details>" >> "$REPORT_FILE"
        echo "<summary>📋 Last ${LOG_LINES} log lines</summary>" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        echo '```' >> "$REPORT_FILE"
        timeout 15 docker logs "${container_name}" --tail ${LOG_LINES} 2>&1 >> "$REPORT_FILE" || echo "Failed to retrieve logs" >> "$REPORT_FILE"
        echo '```' >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        echo "</details>" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"

        echo "  → Collected logs for ${container_name}"
    fi
done < "$TEMP_FILE"

if [[ "$UNHEALTHY_FOUND" == "false" ]]; then
    echo "✅ No unhealthy services detected." >> "$REPORT_FILE"
    echo "  No unhealthy services found."
fi

# Healthy services
cat >> "$REPORT_FILE" << 'EOF'

### 🟢 Healthy Services

EOF

if [[ ${HEALTHY_COUNT} -eq 0 ]]; then
    echo "❌ No healthy services detected!" >> "$REPORT_FILE"
else
    echo "The following services are running and healthy:" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    while IFS='|' read -r icon service container_name status health created ports; do
        if [[ "$icon" == "🟢" ]]; then
            echo "- ✅ **${service}** (\`${container_name}\`) - ${status}" >> "$REPORT_FILE"
        fi
    done < "$TEMP_FILE"
fi

# ============================================
# RECOMMENDATIONS
# ============================================

cat >> "$REPORT_FILE" << EOF

---

## Diagnostic Information

### Port Bindings Check
\`\`\`
$(docker ps -a --format "table {{.Names}}\t{{.Ports}}" | grep ${TEAM_PREFIX})
\`\`\`

### Container Restart Counts
\`\`\`
$(docker ps -a --format "table {{.Names}}\t{{.Status}}" | grep ${TEAM_PREFIX})
\`\`\`

### Recent Docker Events
\`\`\`
$(docker events --since 1h --until 1s 2>&1 | grep -i ${TEAM_PREFIX} | tail -50 || echo "No recent events")
\`\`\`

---

## Recommendations

EOF

# Recommendations
if [[ ${FAILED_COUNT} -gt 0 ]]; then
    cat >> "$REPORT_FILE" << EOF

### ⚠️ Critical Actions Required:

1. **${FAILED_COUNT} service(s) have failed** - Review logs above
2. Common fixes to try:
   - Check \`.env\` file exists and has correct values
   - Verify all required environment variables are set
   - Check port conflicts with: \`ss -tulpn | grep <port>\`
   - Review dependency startup order
   - Check disk space: \`df -h\`
   - Check memory: \`free -h\`
3. To restart failed services:
   \`\`\`bash
   docker compose restart <service-name>
   # or
   docker restart ${TEAM_PREFIX}-<service-name>
   \`\`\`

EOF
fi

if [[ ${UNHEALTHY_COUNT} -gt 0 ]]; then
    cat >> "$REPORT_FILE" << EOF

### 🟡 Health Check Failures:

1. **${UNHEALTHY_COUNT} service(s) are unhealthy** - Services running but health checks failing
2. Troubleshooting steps:
   - Review health check logs in detailed analysis above
   - Check if service ports are accessible internally
   - Verify dependencies are healthy
   - Consider increasing healthcheck timeout/interval in docker-compose
   - Try manual health check: \`curl -f http://localhost:<port>/health\`
3. To view live logs:
   \`\`\`bash
   docker logs -f ${TEAM_PREFIX}-<service-name>
   \`\`\`

EOF
fi

if [[ ${FAILED_COUNT} -eq 0 ]] && [[ ${UNHEALTHY_COUNT} -eq 0 ]]; then
    cat >> "$REPORT_FILE" << EOF

### ✅ All Services Healthy!

No immediate action required. Recommended maintenance:
- Monitor resource usage with \`docker stats\`
- Review logs periodically for warnings
- Keep services updated (Watchtower is running)
- Backup volumes regularly
- Check for security updates

EOF
fi

cat >> "$REPORT_FILE" << EOF

---

## Quick Commands Reference

\`\`\`bash
# View all containers
docker ps -a

# View service logs
docker logs -f ${TEAM_PREFIX}-<service-name>

# Restart a service
docker compose restart <service-name>

# Restart all services
docker compose restart

# Check resource usage
docker stats

# Clean up unused resources
docker system prune -a

# View network
docker network inspect bridge
\`\`\`

---

*Report generated by OpenWebUI Health Check Script v2.0*
*Timestamp: $(date +"%Y-%m-%d %H:%M:%S %Z")*
EOF

# Cleanup
rm -f "$TEMP_FILE"

# Final output
echo ""
echo "========================================"
echo -e "${GREEN}✓ Report Generated Successfully!${NC}"
echo "========================================"
echo ""
echo "Report saved to: ${REPORT_FILE}"
echo ""
echo "📊 Quick Statistics:"
echo -e "  ${RED}Failed:    ${FAILED_COUNT}/${TOTAL_COUNT}${NC}"
echo -e "  ${YELLOW}Unhealthy: ${UNHEALTHY_COUNT}/${TOTAL_COUNT}${NC}"
echo -e "  ${GREEN}Healthy:   ${HEALTHY_COUNT}/${TOTAL_COUNT}${NC}"
echo ""
echo "📖 View report:"
echo "  cat ${REPORT_FILE}"
echo "  # or for better formatting:"
echo "  less ${REPORT_FILE}"
echo ""
echo "========================================"
