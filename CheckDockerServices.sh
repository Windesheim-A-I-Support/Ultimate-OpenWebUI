#!/usr/bin/env bash
set -euo pipefail

# ===== Runtime config via env =====
SINCE="${SINCE:-24h}"             # e.g. 2h, 1d, 2025-09-22T00:00:00
LINES="${LINES:-400}"             # max log lines to scan per container
INCLUDE_STOPPED="${INCLUDE_STOPPED:-0}" # 1 to include stopped containers
VERBOSE="${VERBOSE:-1}"             # 1 = show per-container progress
OUTDIR="${OUTDIR:-.}"             # default: current dir

# ===== Helpers =====
timestamp() { date +"%Y-%m-%d %H:%M:%S%z"; }
dateslug="$(date +"%Y%m%d-%H%M")"
mkdir -p "$OUTDIR"
REPORT_MD="${OUTDIR%/}/docker-log-report-${dateslug}.md"

# ===== Preconditions =====
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker CLI not found in PATH." >&2
  exit 1
fi
if ! docker ps >/dev/null 2>&1; then
  echo "ERROR: cannot talk to Docker daemon (permissions? context?)." >&2
  exit 1
fi

# ===== Container discovery =====
if [[ "$INCLUDE_STOPPED" == "1" ]]; then
  mapfile -t CONTAINERS < <(docker ps -a --format '{{.ID}}')
else
  mapfile -t CONTAINERS < <(docker ps --format '{{.ID}}')
fi

# A list of keywords to search for in the logs
KEYWORDS=( "error" "fail" "fatal" "exception" "traceback" )
declare -A found_issues # Use an associative array to store logs with issues

# ===== Start Report (stdout + file) =====
{
  echo "# Docker Log Report"
  echo "_Generated: $(timestamp)_"
  echo ""
  echo "Lookback: \`--since ${SINCE}\` • Max lines/container: \`${LINES}\` • Include stopped: \`${INCLUDE_STOPPED}\`"
  echo ""
  echo "---"
} > "$REPORT_MD" # Redirect stdout to the report file

# ===== Main loop =====
total_scanned=${#CONTAINERS[@]}
current_count=0

for container_id in "${CONTAINERS[@]}"; do
  current_count=$((current_count + 1))

  # Get container name and status for the report
  container_name="$(docker inspect --format '{{.Name}}' "$container_id" | sed 's|^/||')"
  container_status="$(docker inspect --format '{{.State.Status}}' "$container_id")"
  
  if [[ "$VERBOSE" == "1" ]]; then
    echo "[$current_count/$total_scanned] Scanning logs for container: ${container_name} (${container_status})"
  fi

  # Get logs and search for keywords
  log_output=$(docker logs --since "$SINCE" --tail "$LINES" "$container_id" 2>&1 || true)
  
  # Pipe the logs to a grep search for all keywords
  found_logs=$(printf "%s\n" "$log_output" | grep -i -E "$(IFS='|'; echo "${KEYWORDS[*]}")" || true)

  if [[ -n "$found_logs" ]]; then
    if [[ "$VERBOSE" == "1" ]]; then
      echo "  -> Found issues!"
    fi
    found_issues["$container_id"]="$found_logs"
  fi
done

# ===== Write detailed report section =====
{
  if [[ ${#found_issues[@]} -gt 0 ]]; then
    echo "## Issues Found"
    echo ""
    echo "The following containers had issues in their logs:"
    for container_id in "${!found_issues[@]}"; do
      container_name="$(docker inspect --format '{{.Name}}' "$container_id" | sed 's|^/||')"
      echo "### \`${container_name}\` (\`${container_id}\`)"
      echo "\`\`\`"
      echo "${found_issues[$container_id]}"
      echo "\`\`\`"
      echo ""
    done
  else
    echo "## All Clear"
    echo ""
    echo "No issues found in any container logs for the specified lookback period."
  fi
} >> "$REPORT_MD"

echo ""
echo "---"
echo ""
echo "Log report generated at: ${REPORT_MD}"
echo "Done."