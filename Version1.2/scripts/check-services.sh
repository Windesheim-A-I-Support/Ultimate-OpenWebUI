#!/bin/bash
# ==============================================
# OpenWebUI Team Services Health Check Script
# ==============================================
# Generates a detailed markdown report of all service statuses and logs

set -euo pipefail

# Configuration
TEAM_PREFIX="team1"
LOG_LINES=50
REPORT_DIR="./reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="${REPORT_DIR}/health-report_${TIMESTAMP}.md"

# Service lists
CRITICAL_SERVICES=(
    "litellm"
)

UNHEALTHY_SERVICES=(
    "tika"
    "searxng"
    "qdrant"
    "pipelines"
    "faster-whisper"
)

HEALTHY_SERVICES=(
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

ALL_SERVICES=("${CRITICAL_SERVICES[@]}" "${UNHEALTHY_SERVICES[@]}" "${HEALTHY_SERVICES[@]}")

# Colors for terminal output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create reports directory
mkdir -p "$REPORT_DIR"

# Helper function to get container status
get_container_status() {
    local container_name="$1"
    if docker ps -a --format "{{.Names}}" | grep -q "^${container_name}$"; then
        docker ps -a --filter "name=^${container_name}$" --format "{{.Status}}"
    else
        echo "NOT FOUND"
    fi
}

# Helper function to get container health
get_container_health() {
    local container_name="$1"
    local status=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null || echo "no-healthcheck")
    echo "$status"
}

# Helper function to check if container is running
is_container_running() {
    local container_name="$1"
    docker ps --filter "name=^${container_name}$" --format "{{.Names}}" | grep -q "^${container_name}$"
}

# Start generating report
echo "Generating health report for ${TEAM_PREFIX}..."

cat > "$REPORT_FILE" << 'HEADER'
# OpenWebUI Services Health Report

**Generated:** $(date +"%Y-%m-%d %H:%M:%S %Z")
**Team:** ${TEAM_PREFIX}
**Server:** $(hostname)

---

## Executive Summary

HEADER

# Replace variables in header
sed -i "s/\$(date +\"%Y-%m-%d %H:%M:%S %Z\")/$(date +"%Y-%m-%d %H:%M:%S %Z")/g" "$REPORT_FILE"
sed -i "s/\${TEAM_PREFIX}/${TEAM_PREFIX}/g" "$REPORT_FILE"
sed -i "s/\$(hostname)/$(hostname)/g" "$REPORT_FILE"

# Count statuses
FAILED_COUNT=0
UNHEALTHY_COUNT=0
HEALTHY_COUNT=0
TOTAL_COUNT=${#ALL_SERVICES[@]}

for service in "${ALL_SERVICES[@]}"; do
    container_name="${TEAM_PREFIX}-${service}"
    status=$(get_container_status "$container_name")
    health=$(get_container_health "$container_name")

    if [[ "$status" == *"Exited"* ]] || [[ "$status" == "NOT FOUND" ]]; then
        ((FAILED_COUNT++))
    elif [[ "$health" == "unhealthy" ]]; then
        ((UNHEALTHY_COUNT++))
    elif is_container_running "$container_name"; then
        ((HEALTHY_COUNT++))
    fi
done

# Add summary table
cat >> "$REPORT_FILE" << EOF

| Status | Count | Percentage |
|--------|-------|------------|
| 🔴 Failed/Exited | ${FAILED_COUNT} | $(awk "BEGIN {printf \"%.1f\", (${FAILED_COUNT}/${TOTAL_COUNT})*100}")% |
| 🟡 Unhealthy | ${UNHEALTHY_COUNT} | $(awk "BEGIN {printf \"%.1f\", (${UNHEALTHY_COUNT}/${TOTAL_COUNT})*100}")% |
| 🟢 Healthy | ${HEALTHY_COUNT} | $(awk "BEGIN {printf \"%.1f\", (${HEALTHY_COUNT}/${TOTAL_COUNT})*100}")% |
| **Total** | **${TOTAL_COUNT}** | **100%** |

---

## Service Status Overview

EOF

# Generate status table
echo "" >> "$REPORT_FILE"
echo "| Service | Container Name | Status | Health Check | Uptime |" >> "$REPORT_FILE"
echo "|---------|---------------|---------|--------------|--------|" >> "$REPORT_FILE"

for service in "${ALL_SERVICES[@]}"; do
    container_name="${TEAM_PREFIX}-${service}"
    status=$(get_container_status "$container_name")
    health=$(get_container_health "$container_name")

    # Determine status icon
    if [[ "$status" == *"Exited"* ]] || [[ "$status" == "NOT FOUND" ]]; then
        icon="🔴"
        printf "${RED}✗${NC} %-25s %s\n" "$container_name" "$status"
    elif [[ "$health" == "unhealthy" ]]; then
        icon="🟡"
        printf "${YELLOW}⚠${NC} %-25s %s (unhealthy)\n" "$container_name" "$status"
    elif is_container_running "$container_name"; then
        icon="🟢"
        printf "${GREEN}✓${NC} %-25s %s\n" "$container_name" "$status"
    else
        icon="⚪"
        printf "${BLUE}?${NC} %-25s %s\n" "$container_name" "$status"
    fi

    # Add to report
    echo "| $icon **$service** | \`$container_name\` | $status | $health | - |" >> "$REPORT_FILE"
done

# Add detailed sections
cat >> "$REPORT_FILE" << 'EOF'

---

## Detailed Service Analysis

EOF

# Section 1: Failed Services
echo "" >> "$REPORT_FILE"
echo "### 🔴 Failed Services (Critical)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ ${FAILED_COUNT} -eq 0 ]; then
    echo "✅ No failed services detected." >> "$REPORT_FILE"
else
    for service in "${ALL_SERVICES[@]}"; do
        container_name="${TEAM_PREFIX}-${service}"
        status=$(get_container_status "$container_name")

        if [[ "$status" == *"Exited"* ]] || [[ "$status" == "NOT FOUND" ]]; then
            echo "" >> "$REPORT_FILE"
            echo "#### ${service}" >> "$REPORT_FILE"
            echo "" >> "$REPORT_FILE"
            echo "**Container:** \`${container_name}\`  " >> "$REPORT_FILE"
            echo "**Status:** ${status}  " >> "$REPORT_FILE"
            echo "" >> "$REPORT_FILE"

            if [[ "$status" != "NOT FOUND" ]]; then
                echo "<details>" >> "$REPORT_FILE"
                echo "<summary>📋 Last ${LOG_LINES} log lines</summary>" >> "$REPORT_FILE"
                echo "" >> "$REPORT_FILE"
                echo '```' >> "$REPORT_FILE"
                docker logs "${container_name}" --tail ${LOG_LINES} 2>&1 >> "$REPORT_FILE" || echo "Failed to retrieve logs" >> "$REPORT_FILE"
                echo '```' >> "$REPORT_FILE"
                echo "" >> "$REPORT_FILE"
                echo "</details>" >> "$REPORT_FILE"
            fi
            echo "" >> "$REPORT_FILE"
        fi
    done
fi

# Section 2: Unhealthy Services
echo "" >> "$REPORT_FILE"
echo "### 🟡 Unhealthy Services (Running but failing health checks)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ ${UNHEALTHY_COUNT} -eq 0 ]; then
    echo "✅ No unhealthy services detected." >> "$REPORT_FILE"
else
    for service in "${ALL_SERVICES[@]}"; do
        container_name="${TEAM_PREFIX}-${service}"
        health=$(get_container_health "$container_name")

        if [[ "$health" == "unhealthy" ]]; then
            echo "" >> "$REPORT_FILE"
            echo "#### ${service}" >> "$REPORT_FILE"
            echo "" >> "$REPORT_FILE"
            echo "**Container:** \`${container_name}\`  " >> "$REPORT_FILE"
            echo "**Health Status:** ${health}  " >> "$REPORT_FILE"
            echo "" >> "$REPORT_FILE"

            echo "<details>" >> "$REPORT_FILE"
            echo "<summary>📋 Last ${LOG_LINES} log lines</summary>" >> "$REPORT_FILE"
            echo "" >> "$REPORT_FILE"
            echo '```' >> "$REPORT_FILE"
            docker logs "${container_name}" --tail ${LOG_LINES} 2>&1 >> "$REPORT_FILE" || echo "Failed to retrieve logs" >> "$REPORT_FILE"
            echo '```' >> "$REPORT_FILE"
            echo "" >> "$REPORT_FILE"
            echo "</details>" >> "$REPORT_FILE"
            echo "" >> "$REPORT_FILE"
        fi
    done
fi

# Section 3: Healthy Services
echo "" >> "$REPORT_FILE"
echo "### 🟢 Healthy Services" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ ${HEALTHY_COUNT} -eq 0 ]; then
    echo "❌ No healthy services detected!" >> "$REPORT_FILE"
else
    echo "The following services are running and healthy:" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    for service in "${ALL_SERVICES[@]}"; do
        container_name="${TEAM_PREFIX}-${service}"
        health=$(get_container_health "$container_name")

        if is_container_running "$container_name" && [[ "$health" != "unhealthy" ]]; then
            status=$(get_container_status "$container_name")
            echo "- ✅ **${service}** (\`${container_name}\`) - ${status}" >> "$REPORT_FILE"
        fi
    done
fi

# Add system information
cat >> "$REPORT_FILE" << EOF

---

## System Information

**Docker Version:**
\`\`\`
$(docker --version)
\`\`\`

**Docker Compose Version:**
\`\`\`
$(docker compose version 2>/dev/null || docker-compose --version 2>/dev/null || echo "Not found")
\`\`\`

**System Resources:**
\`\`\`
$(docker system df)
\`\`\`

**Network Status:**
\`\`\`
$(docker network ls | grep ${TEAM_PREFIX} || echo "No team-specific networks found")
\`\`\`

**Volume Status:**
\`\`\`
$(docker volume ls | grep ${TEAM_PREFIX} || echo "No team-specific volumes found")
\`\`\`

---

## Recommendations

EOF

# Generate recommendations based on status
if [ ${FAILED_COUNT} -gt 0 ]; then
    echo "" >> "$REPORT_FILE"
    echo "### Critical Actions Required:" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "1. ⚠️ **${FAILED_COUNT} service(s) have failed** - Review logs above and restart/fix configuration" >> "$REPORT_FILE"
    echo "2. Check the detailed logs in the 'Failed Services' section" >> "$REPORT_FILE"
    echo "3. Verify environment variables are set correctly in \`.env\` file" >> "$REPORT_FILE"
fi

if [ ${UNHEALTHY_COUNT} -gt 0 ]; then
    echo "" >> "$REPORT_FILE"
    echo "### Health Check Failures:" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "1. ⚠️ **${UNHEALTHY_COUNT} service(s) are unhealthy** - Services running but health checks failing" >> "$REPORT_FILE"
    echo "2. Review logs for each unhealthy service" >> "$REPORT_FILE"
    echo "3. Verify service dependencies are running" >> "$REPORT_FILE"
    echo "4. Check if ports are accessible and not blocked" >> "$REPORT_FILE"
fi

if [ ${FAILED_COUNT} -eq 0 ] && [ ${UNHEALTHY_COUNT} -eq 0 ]; then
    echo "" >> "$REPORT_FILE"
    echo "✅ **All services are healthy!** No immediate action required." >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "Recommended maintenance tasks:" >> "$REPORT_FILE"
    echo "- Monitor resource usage" >> "$REPORT_FILE"
    echo "- Review logs for warnings" >> "$REPORT_FILE"
    echo "- Keep services updated via Watchtower" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "*Report generated by OpenWebUI Health Check Script v1.0*" >> "$REPORT_FILE"

# Finish
echo ""
echo -e "${GREEN}✓ Report generated successfully!${NC}"
echo ""
echo "Report saved to: ${REPORT_FILE}"
echo ""
echo "Quick stats:"
echo -e "  ${RED}Failed:${NC} ${FAILED_COUNT}/${TOTAL_COUNT}"
echo -e "  ${YELLOW}Unhealthy:${NC} ${UNHEALTHY_COUNT}/${TOTAL_COUNT}"
echo -e "  ${GREEN}Healthy:${NC} ${HEALTHY_COUNT}/${TOTAL_COUNT}"
echo ""
echo "View report with: cat ${REPORT_FILE}"
echo "Or open in markdown viewer for better formatting"
