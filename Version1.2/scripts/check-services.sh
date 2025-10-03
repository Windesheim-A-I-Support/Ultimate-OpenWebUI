#!/bin/bash
# ==============================================
# OpenWebUI Team Services Health Check Script
# Multi-Team Edition - v2.0
# ==============================================
# Generates a detailed markdown report of all service statuses and logs
#
# Usage:
#   ./check-services.sh              # Scan all teams and services
#   ./check-services.sh team1        # Scan only team1 containers
#   ./check-services.sh team2        # Scan only team2 containers
#
# Features:
#   - Automatic container discovery using Docker IDs
#   - Multi-team support
#   - Comprehensive error handling
#   - Detailed logs for failed/unhealthy services
#   - System resource information
#   - Generates markdown reports with timestamps
#
# Environment Variables:
#   LOG_LINES    - Number of log lines to include (default: 50)
#   REPORT_DIR   - Directory for reports (default: ./reports)

# More robust error handling - don't exit on error, capture and report them
set -uo pipefail

# Global error tracking
declare -a SCRIPT_ERRORS
declare -a SCRIPT_WARNINGS

# Error handler function
log_error() {
    local message="$1"
    SCRIPT_ERRORS+=("$message")
    echo -e "\033[0;31m[ERROR]\033[0m $message" >&2
}

log_warning() {
    local message="$1"
    SCRIPT_WARNINGS+=("$message")
    echo -e "\033[1;33m[WARNING]\033[0m $message" >&2
}

log_info() {
    local message="$1"
    echo -e "\033[0;34m[INFO]\033[0m $message"
}

# Trap any unhandled errors
trap 'log_error "Script encountered an error at line $LINENO"' ERR

# Configuration with validation
TEAM_PREFIX="${1:-}"  # First argument or empty (will discover all teams)
LOG_LINES="${LOG_LINES:-50}"
REPORT_DIR="${REPORT_DIR:-./reports}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S" 2>/dev/null || echo "unknown")

# Discovered containers (will be populated by discovery function)
declare -A DISCOVERED_CONTAINERS  # Maps "team-service" -> container_id
declare -a DISCOVERED_TEAMS       # Array of unique team prefixes found
declare -a ALL_SERVICES           # All discovered service names (without team prefix)

# Colors for terminal output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Validate prerequisites
validate_prerequisites() {
    log_info "Validating prerequisites..."

    # Check if docker is available
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed or not in PATH"
        return 1
    fi

    # Check if docker daemon is running
    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running or not accessible"
        return 1
    fi

    # Check if awk is available (for percentage calculations)
    if ! command -v awk &> /dev/null; then
        log_warning "awk is not available, percentage calculations may fail"
    fi

    return 0
}

# Create reports directory with error handling
create_report_directory() {
    if ! mkdir -p "$REPORT_DIR" 2>/dev/null; then
        log_error "Failed to create report directory: $REPORT_DIR"
        # Try fallback directory
        REPORT_DIR="/tmp/openwebui-reports"
        log_warning "Using fallback directory: $REPORT_DIR"
        if ! mkdir -p "$REPORT_DIR" 2>/dev/null; then
            log_error "Failed to create fallback directory: $REPORT_DIR"
            return 1
        fi
        REPORT_FILE="${REPORT_DIR}/health-report_${TIMESTAMP}.md"
    fi
    return 0
}

# Discover all containers dynamically
discover_containers() {
    log_info "Discovering all containers..."

    local team_filter=""
    if [[ -n "$TEAM_PREFIX" ]]; then
        team_filter="$TEAM_PREFIX"
        log_info "Filtering by team prefix: $TEAM_PREFIX"
    else
        log_info "Discovering all teams and services..."
    fi

    # Get all containers with their IDs and names
    local containers
    containers=$(docker ps -a --format "{{.ID}}|{{.Names}}" 2>/dev/null || echo "")

    if [[ -z "$containers" ]]; then
        log_warning "No containers found on this system"
        return 0
    fi

    declare -A unique_services  # Track unique service names

    # Process each container
    while IFS='|' read -r container_id container_name; do
        [[ -z "$container_id" ]] && continue

        # If team filter specified, skip non-matching containers
        if [[ -n "$team_filter" ]] && [[ ! "$container_name" =~ ^${team_filter}- ]]; then
            continue
        fi

        # Extract team prefix (everything before first dash followed by service name)
        # Example: team1-openwebui -> team1, openwebui
        # Also handle: openwebui-team1 or just openwebui
        local team=""
        local service=""

        # Pattern 1: team-service format (most common)
        if [[ "$container_name" =~ ^([^-]+)-(.+)$ ]]; then
            local possible_team="${BASH_REMATCH[1]}"
            local possible_service="${BASH_REMATCH[2]}"

            # Check if it looks like a team prefix (teamN, team-N, etc.)
            if [[ "$possible_team" =~ ^team[0-9]*$ ]] || [[ -n "$team_filter" ]]; then
                team="$possible_team"
                service="$possible_service"
            else
                # Might be service-other format, treat whole name as service
                service="$container_name"
                team="default"
            fi
        else
            # No dash, treat as standalone service
            service="$container_name"
            team="default"
        fi

        # Store container info using composite key: team-service
        DISCOVERED_CONTAINERS["${team}-${service}"]="$container_id"

        # Track unique teams (safely handle first item)
        local team_exists=0
        for existing_team in "${DISCOVERED_TEAMS[@]+"${DISCOVERED_TEAMS[@]}"}"; do
            if [[ "$existing_team" == "$team" ]]; then
                team_exists=1
                break
            fi
        done

        if [[ $team_exists -eq 0 ]]; then
            DISCOVERED_TEAMS+=("$team")
        fi

        # Track unique services
        unique_services["$service"]=1

        log_info "Found: $container_name (ID: ${container_id:0:12}) -> team=$team, service=$service"
    done <<< "$containers"

    # Convert unique services to array (safely handle empty case)
    local container_count=0
    local team_count=0
    local service_count=0

    if [[ -n "${unique_services+x}" ]]; then
        if [[ ${#unique_services[@]} -gt 0 ]]; then
            ALL_SERVICES=("${!unique_services[@]}")
            service_count=${#ALL_SERVICES[@]}
        else
            ALL_SERVICES=()
        fi
    else
        ALL_SERVICES=()
    fi

    log_info "Discovery complete: ${#DISCOVERED_CONTAINERS[@]} containers from ${#DISCOVERED_TEAMS[@]} team(s), ${service_count} unique service(s)"
}

# Helper function to get container status by ID
get_container_status_by_id() {
    local container_id="$1"
    local status

    status=$(docker inspect --format='{{.State.Status}}' "$container_id" 2>/dev/null)
    if [[ -z "$status" ]]; then
        echo "ERROR: Unable to retrieve status"
    else
        # Get more detailed status with uptime
        local detailed_status
        detailed_status=$(docker ps -a --filter "id=$container_id" --format "{{.Status}}" 2>/dev/null)
        if [[ -n "$detailed_status" ]]; then
            echo "$detailed_status"
        else
            echo "$status"
        fi
    fi
}

# Helper function to get container health by ID
get_container_health_by_id() {
    local container_id="$1"
    local health

    health=$(docker inspect --format='{{.State.Health.Status}}' "$container_id" 2>/dev/null)
    if [[ -z "$health" ]] || [[ "$health" == "<no value>" ]]; then
        echo "no-healthcheck"
    else
        echo "$health"
    fi
}

# Helper function to check if container is running by ID
is_container_running_by_id() {
    local container_id="$1"
    local state
    state=$(docker inspect --format='{{.State.Running}}' "$container_id" 2>/dev/null)
    [[ "$state" == "true" ]]
    return $?
}

# Helper function to get container name by ID
get_container_name_by_id() {
    local container_id="$1"
    docker inspect --format='{{.Name}}' "$container_id" 2>/dev/null | sed 's/^\///'
}

# Safe append to report file
safe_append() {
    local content="$1"
    if ! echo "$content" >> "$REPORT_FILE" 2>/dev/null; then
        log_error "Failed to write to report file: $REPORT_FILE"
        return 1
    fi
    return 0
}

# Initialize report file with error handling
initialize_report() {
    local team_info="$1"

    # Set report file name based on team
    if [[ -n "$team_info" ]]; then
        REPORT_FILE="${REPORT_DIR}/health-report_${team_info}_${TIMESTAMP}.md"
    else
        REPORT_FILE="${REPORT_DIR}/health-report_all-teams_${TIMESTAMP}.md"
    fi

    log_info "Initializing report file: $REPORT_FILE"

    if ! cat > "$REPORT_FILE" 2>/dev/null << 'HEADER'
# OpenWebUI Services Health Report

**Generated:** TIMESTAMP_PLACEHOLDER
**Team(s):** TEAM_PREFIX_PLACEHOLDER
**Server:** HOSTNAME_PLACEHOLDER
**Container Discovery:** ID-based (supports multiple teams)

---

## Executive Summary

HEADER
    then
        log_error "Failed to initialize report file"
        return 1
    fi

    # Replace placeholders safely
    local current_date=$(date +"%Y-%m-%d %H:%M:%S %Z" 2>/dev/null || echo "Unknown")
    local current_hostname=$(hostname 2>/dev/null || echo "Unknown")
    local team_display="${team_info:-All Teams}"

    if command -v sed &> /dev/null; then
        sed -i "s/TIMESTAMP_PLACEHOLDER/${current_date}/g" "$REPORT_FILE" 2>/dev/null || log_warning "Failed to replace timestamp"
        sed -i "s/TEAM_PREFIX_PLACEHOLDER/${team_display}/g" "$REPORT_FILE" 2>/dev/null || log_warning "Failed to replace team prefix"
        sed -i "s/HOSTNAME_PLACEHOLDER/${current_hostname}/g" "$REPORT_FILE" 2>/dev/null || log_warning "Failed to replace hostname"
    else
        log_warning "sed not available, placeholders not replaced"
    fi

    return 0
}

# Count service statuses with error handling
count_service_statuses() {
    log_info "Counting service statuses..."

    FAILED_COUNT=0
    UNHEALTHY_COUNT=0
    HEALTHY_COUNT=0
    TOTAL_COUNT=${#DISCOVERED_CONTAINERS[@]}

    for key in "${!DISCOVERED_CONTAINERS[@]}"; do
        local container_id="${DISCOVERED_CONTAINERS[$key]}"

        # Get status and health with error handling
        status=$(get_container_status_by_id "$container_id" 2>/dev/null || echo "ERROR")
        health=$(get_container_health_by_id "$container_id" 2>/dev/null || echo "error")

        if [[ "$status" == *"exited"* ]] || [[ "$status" == *"Exited"* ]] || [[ "$status" == "ERROR"* ]]; then
            ((FAILED_COUNT++)) || true
        elif [[ "$health" == "unhealthy" ]]; then
            ((UNHEALTHY_COUNT++)) || true
        elif is_container_running_by_id "$container_id" 2>/dev/null; then
            ((HEALTHY_COUNT++)) || true
        fi
    done
}

# Generate summary table with error handling
generate_summary_table() {
    log_info "Generating summary table..."

    local failed_pct="0.0"
    local unhealthy_pct="0.0"
    local healthy_pct="0.0"

    # Calculate percentages safely
    if command -v awk &> /dev/null && [[ $TOTAL_COUNT -gt 0 ]]; then
        failed_pct=$(awk "BEGIN {printf \"%.1f\", (${FAILED_COUNT}/${TOTAL_COUNT})*100}" 2>/dev/null || echo "0.0")
        unhealthy_pct=$(awk "BEGIN {printf \"%.1f\", (${UNHEALTHY_COUNT}/${TOTAL_COUNT})*100}" 2>/dev/null || echo "0.0")
        healthy_pct=$(awk "BEGIN {printf \"%.1f\", (${HEALTHY_COUNT}/${TOTAL_COUNT})*100}" 2>/dev/null || echo "0.0")
    fi

    cat >> "$REPORT_FILE" 2>/dev/null << EOF

| Status | Count | Percentage |
|--------|-------|------------|
| 🔴 Failed/Exited | ${FAILED_COUNT} | ${failed_pct}% |
| 🟡 Unhealthy | ${UNHEALTHY_COUNT} | ${unhealthy_pct}% |
| 🟢 Healthy | ${HEALTHY_COUNT} | ${healthy_pct}% |
| **Total** | **${TOTAL_COUNT}** | **100%** |

---

## Service Status Overview

EOF
}

# Generate service status table
generate_status_table() {
    log_info "Generating service status table..."

    {
        echo ""
        echo "| Service | Team | Container Name | Container ID | Status | Health Check |"
        echo "|---------|------|----------------|--------------|--------|--------------|"
    } >> "$REPORT_FILE" 2>/dev/null || log_error "Failed to write status table header"

    # Sort keys for consistent output
    local sorted_keys=()
    IFS=$'\n' sorted_keys=($(for key in "${!DISCOVERED_CONTAINERS[@]}"; do echo "$key"; done | sort))

    for key in "${sorted_keys[@]}"; do
        local container_id="${DISCOVERED_CONTAINERS[$key]}"

        # Extract team and service from key
        local team="${key%%-*}"
        local service="${key#*-}"

        local container_name=$(get_container_name_by_id "$container_id" 2>/dev/null || echo "unknown")
        local status=$(get_container_status_by_id "$container_id" 2>/dev/null || echo "ERROR")
        local health=$(get_container_health_by_id "$container_id" 2>/dev/null || echo "error")
        local short_id="${container_id:0:12}"

        # Determine status icon
        local icon="⚪"
        if [[ "$status" == *"exited"* ]] || [[ "$status" == *"Exited"* ]] || [[ "$status" == "ERROR"* ]]; then
            icon="🔴"
            printf "${RED}✗${NC} %-30s %s\n" "$container_name" "$status"
        elif [[ "$health" == "unhealthy" ]]; then
            icon="🟡"
            printf "${YELLOW}⚠${NC} %-30s %s (unhealthy)\n" "$container_name" "$status"
        elif is_container_running_by_id "$container_id" 2>/dev/null; then
            icon="🟢"
            printf "${GREEN}✓${NC} %-30s %s\n" "$container_name" "$status"
        else
            printf "${BLUE}?${NC} %-30s %s\n" "$container_name" "$status"
        fi

        # Add to report
        echo "| $icon **$service** | $team | \`$container_name\` | \`$short_id\` | $status | $health |" >> "$REPORT_FILE" 2>/dev/null || log_warning "Failed to write status for $service"
    done
}

# Generate detailed service analysis
generate_detailed_analysis() {
    log_info "Generating detailed service analysis..."

    cat >> "$REPORT_FILE" 2>/dev/null << 'EOF'

---

## Detailed Service Analysis

EOF

    # Section 1: Failed Services
    {
        echo ""
        echo "### 🔴 Failed Services (Critical)"
        echo ""
    } >> "$REPORT_FILE" 2>/dev/null

    if [ ${FAILED_COUNT} -eq 0 ]; then
        echo "✅ No failed services detected." >> "$REPORT_FILE" 2>/dev/null
    else
        local sorted_keys=()
        IFS=$'\n' sorted_keys=($(for key in "${!DISCOVERED_CONTAINERS[@]}"; do echo "$key"; done | sort))

        for key in "${sorted_keys[@]}"; do
            local container_id="${DISCOVERED_CONTAINERS[$key]}"
            local container_name=$(get_container_name_by_id "$container_id" 2>/dev/null || echo "unknown")
            local status=$(get_container_status_by_id "$container_id" 2>/dev/null || echo "ERROR")
            local team="${key%%-*}"
            local service="${key#*-}"
            local short_id="${container_id:0:12}"

            if [[ "$status" == *"exited"* ]] || [[ "$status" == *"Exited"* ]] || [[ "$status" == "ERROR"* ]]; then
                {
                    echo ""
                    echo "#### ${team} - ${service}"
                    echo ""
                    echo "**Container:** \`${container_name}\`  "
                    echo "**Container ID:** \`${short_id}\`  "
                    echo "**Team:** ${team}  "
                    echo "**Service:** ${service}  "
                    echo "**Status:** ${status}  "
                    echo ""
                    echo "<details>"
                    echo "<summary>📋 Last ${LOG_LINES} log lines</summary>"
                    echo ""
                    echo '```'
                } >> "$REPORT_FILE" 2>/dev/null

                # Safely retrieve logs by ID
                if docker logs "$container_id" --tail ${LOG_LINES} 2>&1 >> "$REPORT_FILE" 2>/dev/null; then
                    true
                else
                    echo "Failed to retrieve logs - container may not be accessible" >> "$REPORT_FILE" 2>/dev/null
                fi

                {
                    echo '```'
                    echo ""
                    echo "</details>"
                    echo ""
                } >> "$REPORT_FILE" 2>/dev/null
            fi
        done
    fi

    # Section 2: Unhealthy Services
    {
        echo ""
        echo "### 🟡 Unhealthy Services (Running but failing health checks)"
        echo ""
    } >> "$REPORT_FILE" 2>/dev/null

    if [ ${UNHEALTHY_COUNT} -eq 0 ]; then
        echo "✅ No unhealthy services detected." >> "$REPORT_FILE" 2>/dev/null
    else
        local sorted_keys=()
        IFS=$'\n' sorted_keys=($(for key in "${!DISCOVERED_CONTAINERS[@]}"; do echo "$key"; done | sort))

        for key in "${sorted_keys[@]}"; do
            local container_id="${DISCOVERED_CONTAINERS[$key]}"
            local container_name=$(get_container_name_by_id "$container_id" 2>/dev/null || echo "unknown")
            local health=$(get_container_health_by_id "$container_id" 2>/dev/null || echo "error")
            local team="${key%%-*}"
            local service="${key#*-}"
            local short_id="${container_id:0:12}"

            if [[ "$health" == "unhealthy" ]]; then
                {
                    echo ""
                    echo "#### ${team} - ${service}"
                    echo ""
                    echo "**Container:** \`${container_name}\`  "
                    echo "**Container ID:** \`${short_id}\`  "
                    echo "**Team:** ${team}  "
                    echo "**Service:** ${service}  "
                    echo "**Health Status:** ${health}  "
                    echo ""
                    echo "<details>"
                    echo "<summary>📋 Last ${LOG_LINES} log lines</summary>"
                    echo ""
                    echo '```'
                } >> "$REPORT_FILE" 2>/dev/null

                # Safely retrieve logs by ID
                if docker logs "$container_id" --tail ${LOG_LINES} 2>&1 >> "$REPORT_FILE" 2>/dev/null; then
                    true
                else
                    echo "Failed to retrieve logs" >> "$REPORT_FILE" 2>/dev/null
                fi

                {
                    echo '```'
                    echo ""
                    echo "</details>"
                    echo ""
                } >> "$REPORT_FILE" 2>/dev/null
            fi
        done
    fi

    # Section 3: Healthy Services
    {
        echo ""
        echo "### 🟢 Healthy Services"
        echo ""
    } >> "$REPORT_FILE" 2>/dev/null

    if [ ${HEALTHY_COUNT} -eq 0 ]; then
        echo "❌ No healthy services detected!" >> "$REPORT_FILE" 2>/dev/null
    else
        {
            echo "The following services are running and healthy:"
            echo ""
        } >> "$REPORT_FILE" 2>/dev/null

        local sorted_keys=()
        IFS=$'\n' sorted_keys=($(for key in "${!DISCOVERED_CONTAINERS[@]}"; do echo "$key"; done | sort))

        for key in "${sorted_keys[@]}"; do
            local container_id="${DISCOVERED_CONTAINERS[$key]}"
            local container_name=$(get_container_name_by_id "$container_id" 2>/dev/null || echo "unknown")
            local health=$(get_container_health_by_id "$container_id" 2>/dev/null || echo "error")
            local team="${key%%-*}"
            local service="${key#*-}"

            if is_container_running_by_id "$container_id" 2>/dev/null && [[ "$health" != "unhealthy" ]]; then
                local status=$(get_container_status_by_id "$container_id" 2>/dev/null || echo "ERROR")
                echo "- ✅ **${team} - ${service}** (\`${container_name}\`) - ${status}" >> "$REPORT_FILE" 2>/dev/null
            fi
        done
    fi
}

# Generate system information section
generate_system_info() {
    log_info "Generating system information..."

    local docker_version=$(docker --version 2>/dev/null || echo "Error retrieving Docker version")
    local compose_version=$(docker compose version 2>/dev/null || docker-compose --version 2>/dev/null || echo "Not found")
    local system_df=$(docker system df 2>/dev/null || echo "Error retrieving system information")

    # Get networks and volumes for discovered teams
    local networks_info=""
    local volumes_info=""

    if [[ ${#DISCOVERED_TEAMS[@]} -gt 0 ]]; then
        for team in "${DISCOVERED_TEAMS[@]}"; do
            networks_info+="## Team: $team\n"
            networks_info+="$(docker network ls 2>/dev/null | grep ${team} || echo 'No networks found')\n\n"

            volumes_info+="## Team: $team\n"
            volumes_info+="$(docker volume ls 2>/dev/null | grep ${team} || echo 'No volumes found')\n\n"
        done
    else
        networks_info="No team containers discovered"
        volumes_info="No team containers discovered"
    fi

    {
        echo ""
        echo "---"
        echo ""
        echo "## System Information"
        echo ""
        echo "**Docker Version:**"
        echo '```'
        echo "${docker_version}"
        echo '```'
        echo ""
        echo "**Docker Compose Version:**"
        echo '```'
        echo "${compose_version}"
        echo '```'
        echo ""
        echo "**System Resources:**"
        echo '```'
        echo "${system_df}"
        echo '```'
        echo ""
        echo "**Network Status:**"
        echo '```'
        echo -e "${networks_info}"
        echo '```'
        echo ""
        echo "**Volume Status:**"
        echo '```'
        echo -e "${volumes_info}"
        echo '```'
        echo ""
        echo "---"
        echo ""
        echo "## Recommendations"
        echo ""
    } >> "$REPORT_FILE" 2>/dev/null
}

# Generate recommendations
generate_recommendations() {
    log_info "Generating recommendations..."

    if [ ${FAILED_COUNT} -gt 0 ]; then
        {
            echo ""
            echo "### Critical Actions Required:"
            echo ""
            echo "1. ⚠️ **${FAILED_COUNT} service(s) have failed** - Review logs above and restart/fix configuration"
            echo "2. Check the detailed logs in the 'Failed Services' section"
            echo "3. Verify environment variables are set correctly in \`.env\` file"
        } >> "$REPORT_FILE" 2>/dev/null
    fi

    if [ ${UNHEALTHY_COUNT} -gt 0 ]; then
        {
            echo ""
            echo "### Health Check Failures:"
            echo ""
            echo "1. ⚠️ **${UNHEALTHY_COUNT} service(s) are unhealthy** - Services running but health checks failing"
            echo "2. Review logs for each unhealthy service"
            echo "3. Verify service dependencies are running"
            echo "4. Check if ports are accessible and not blocked"
        } >> "$REPORT_FILE" 2>/dev/null
    fi

    if [ ${FAILED_COUNT} -eq 0 ] && [ ${UNHEALTHY_COUNT} -eq 0 ]; then
        {
            echo ""
            echo "✅ **All services are healthy!** No immediate action required."
            echo ""
            echo "Recommended maintenance tasks:"
            echo "- Monitor resource usage"
            echo "- Review logs for warnings"
            echo "- Keep services updated via Watchtower"
        } >> "$REPORT_FILE" 2>/dev/null
    fi
}

# Add script errors section if any occurred
add_script_errors() {
    # Check arrays exist and have elements safely
    local has_errors=0
    local has_warnings=0

    if [[ -n "${SCRIPT_ERRORS+x}" ]] && [[ ${#SCRIPT_ERRORS[@]} -gt 0 ]]; then
        has_errors=1
    fi

    if [[ -n "${SCRIPT_WARNINGS+x}" ]] && [[ ${#SCRIPT_WARNINGS[@]} -gt 0 ]]; then
        has_warnings=1
    fi

    if [[ $has_errors -eq 1 ]] || [[ $has_warnings -eq 1 ]]; then
        {
            echo ""
            echo "---"
            echo ""
            echo "## Script Execution Issues"
            echo ""
        } >> "$REPORT_FILE" 2>/dev/null

        if [[ $has_errors -eq 1 ]]; then
            {
                echo "### Errors:"
                echo ""
            } >> "$REPORT_FILE" 2>/dev/null

            for error in "${SCRIPT_ERRORS[@]}"; do
                echo "- 🔴 $error" >> "$REPORT_FILE" 2>/dev/null
            done
            echo "" >> "$REPORT_FILE" 2>/dev/null
        fi

        if [[ $has_warnings -eq 1 ]]; then
            {
                echo "### Warnings:"
                echo ""
            } >> "$REPORT_FILE" 2>/dev/null

            for warning in "${SCRIPT_WARNINGS[@]}"; do
                echo "- 🟡 $warning" >> "$REPORT_FILE" 2>/dev/null
            done
            echo "" >> "$REPORT_FILE" 2>/dev/null
        fi
    fi
}

# Finalize report
finalize_report() {
    {
        echo ""
        echo "---"
        echo ""
        echo "*Report generated by OpenWebUI Health Check Script v2.0 (Multi-Team Edition)*"
    } >> "$REPORT_FILE" 2>/dev/null || log_error "Failed to finalize report"
}

# Print summary to console
print_summary() {
    echo ""
    echo -e "${GREEN}✓ Report generated successfully!${NC}"
    echo ""
    echo "Report saved to: ${REPORT_FILE}"
    echo ""
    echo "Quick stats:"
    echo -e "  ${RED}Failed:${NC} ${FAILED_COUNT}/${TOTAL_COUNT}"
    echo -e "  ${YELLOW}Unhealthy:${NC} ${UNHEALTHY_COUNT}/${TOTAL_COUNT}"
    echo -e "  ${GREEN}Healthy:${NC} ${HEALTHY_COUNT}/${TOTAL_COUNT}"

    if [[ -n "${SCRIPT_ERRORS+x}" ]] && [[ ${#SCRIPT_ERRORS[@]} -gt 0 ]]; then
        echo ""
        echo -e "${RED}Script Errors: ${#SCRIPT_ERRORS[@]}${NC}"
    fi

    if [[ -n "${SCRIPT_WARNINGS+x}" ]] && [[ ${#SCRIPT_WARNINGS[@]} -gt 0 ]]; then
        echo -e "${YELLOW}Script Warnings: ${#SCRIPT_WARNINGS[@]}${NC}"
    fi

    echo ""
    echo "View report with: cat ${REPORT_FILE}"
    echo "Or open in markdown viewer for better formatting"
    echo ""
}

# Main execution
main() {
    log_info "Starting OpenWebUI Services Health Check Script v2.0 (Multi-Team Edition)"

    if [[ -n "$TEAM_PREFIX" ]]; then
        log_info "Team Filter: ${TEAM_PREFIX}"
    else
        log_info "Scanning all teams..."
    fi

    # Validate prerequisites
    if ! validate_prerequisites; then
        log_error "Prerequisites validation failed. Cannot continue."
        exit 1
    fi

    # Discover all containers
    discover_containers

    # Check if any containers were found
    if [[ ${#DISCOVERED_CONTAINERS[@]} -eq 0 ]]; then
        log_error "No containers discovered matching criteria. Exiting."
        if [[ -n "$TEAM_PREFIX" ]]; then
            log_info "Tip: Make sure containers follow the naming pattern '${TEAM_PREFIX}-servicename'"
        fi
        exit 1
    fi

    # Create report directory
    if ! create_report_directory; then
        log_error "Failed to create report directory. Cannot continue."
        exit 1
    fi

    # Initialize report with team info
    local team_label="${TEAM_PREFIX:-all-teams}"
    if ! initialize_report "$team_label"; then
        log_error "Failed to initialize report. Cannot continue."
        exit 1
    fi

    # Count statuses
    count_service_statuses

    # Generate report sections
    generate_summary_table || log_warning "Failed to generate summary table"
    generate_status_table || log_warning "Failed to generate status table"
    generate_detailed_analysis || log_warning "Failed to generate detailed analysis"
    generate_system_info || log_warning "Failed to generate system info"
    generate_recommendations || log_warning "Failed to generate recommendations"

    # Add script errors if any
    add_script_errors

    # Finalize
    finalize_report

    # Print summary
    print_summary

    # Exit with appropriate code
    if [[ -n "${SCRIPT_ERRORS+x}" ]] && [[ ${#SCRIPT_ERRORS[@]} -gt 0 ]]; then
        exit 1
    else
        exit 0
    fi
}

# Run main function
main "$@"
