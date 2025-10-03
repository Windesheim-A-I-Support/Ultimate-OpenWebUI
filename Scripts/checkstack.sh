#!/usr/bin/env bash
# traefik-public-health.sh
# One-shot or watch-mode health checker for your PUBLIC (Traefik) endpoints.
# Add/extend services by appending to the SERVICES array below (name|base_url|space_separated_health_paths).

set -Eeuo pipefail

DOMAIN_ROOT="${DOMAIN_ROOT:-valuechainhackers.xyz}"   # Override: DOMAIN_ROOT=my.tld ./traefik-public-health.sh
EXPECT_IP="${EXPECT_IP:-}"                            # Optional: EXPECT_IP=95.99.112.224 to assert DNS A/AAAA
WATCH_SEC="${WATCH_SEC:-0}"                           # >0 enables watch mode (seconds between refresh)
TIMEOUT="${TIMEOUT:-5}"                               # curl timeout seconds

# name | base_url | paths (space-separated) | expect_regex (optional; case-insensitive)
SERVICES=(
  "openwebui|https://openwebui.${DOMAIN_ROOT}|/health|"
  "n8n|https://n8n.${DOMAIN_ROOT}|/healthz|"
  "flowise|https://flowise.${DOMAIN_ROOT}|/|"
  "supabase-studio|https://supabase.${DOMAIN_ROOT}|/|"
  "ollama|https://ollama.${DOMAIN_ROOT}|/ /api/tags|ollama is running"
  "searxng|https://searxng.${DOMAIN_ROOT}|/|"
  "qdrant|https://qdrant.${DOMAIN_ROOT}|/readyz /healthz /livez|"
  "neo4j|https://neo4j.${DOMAIN_ROOT}|/browser/ /|"
  "langfuse|https://langfuse.${DOMAIN_ROOT}|/api/public/health /api/public/ready|"
  "mcpo|https://mcpo.${DOMAIN_ROOT}|/docs /openapi.json|"
)

CURL_BASE=(-fsS -m "${TIMEOUT}" -o /dev/null -w "%{http_code}")
hr() { printf '%*s\n' "${COLUMNS:-100}" '' | tr ' ' '─'; }

dns_check() {
  local host="$1" ip_ok="N/A"
  if [[ -n "$EXPECT_IP" ]]; then
    # getent works on most GNU systems; fallback to getent hosts only A/AAAA
    local addrs
    addrs="$(getent ahosts "$host" 2>/dev/null | awk '{print $1}' | sort -u || true)"
    if grep -qE "^${EXPECT_IP//./\\.}$" <<<"$addrs"; then ip_ok="OK"; else ip_ok="MISMATCH"; fi
  fi
  printf "%s" "$ip_ok"
}

http_check() {
  local base="$1"; shift
  local code path ok=1
  for path in "$@"; do
    code="$(curl "${CURL_BASE[@]}" "${base}${path}" 2>/dev/null || true)"
    [[ "$code" =~ ^2|3 ]] && { printf "%s" "$code"; ok=0; break; }
  done
  return "$ok"
}

body_grep() {
  local url="$1" re="$2" body
  body="$(curl -fsS -m "${TIMEOUT}" "$url" 2>/dev/null || true)"
  [[ -z "$re" ]] && { printf "skip"; return 0; }
  if grep -qiE "$re" <<<"$body"; then printf "match"; else printf "miss"; fi
}

print_header() {
  echo "Traefik public endpoints health @ $(date '+%Y-%m-%d %H:%M:%S')   domain=${DOMAIN_ROOT}   expect_ip=${EXPECT_IP:-<unset>}"
  hr
  printf "%-15s | %-42s | %-6s | %-10s | %-7s | %s\n" "SERVICE" "BASE" "HTTP" "DNS(IP)" "BODY" "DETAIL"
  hr
}

run_once() {
  print_header
  local row name base paths expect path_list code dmatch bmatch
  for row in "${SERVICES[@]}"; do
    IFS='|' read -r name base paths expect <<<"$row"
    IFS=' ' read -r -a path_list <<<"$paths"

    code="$(http_check "$base" "${path_list[@]}" || true)"
    if [[ -n "$code" && "$code" =~ ^2|3 ]]; then
      status="OK"; emoji="✅"; detail="HTTP ${code}"
    else
      status="DOWN"; emoji="❌"; detail="no 2xx/3xx (last=${code:-ERR})"
    fi

    dmatch="$(dns_check "$(sed -E 's#^https?://([^/]+)/?.*#\1#' <<<"$base")")"
    [[ "$dmatch" == "MISMATCH" ]] && detail="${detail}; DNS→${EXPECT_IP} mismatch"

    # Optional body check on first path if regex provided
    bmatch="skip"
    if [[ -n "${expect:-}" ]]; then
      bmatch="$(body_grep "${base}${path_list[0]}" "$expect")"
      [[ "$bmatch" == "miss" ]] && detail="${detail}; body regex miss"
    fi

    printf "%-15s | %-42s | %-6s | %-10s | %-7s | %s %s\n" \
      "$name" "$base" "$status" "$dmatch" "$bmatch" "$emoji" "$detail"
  done
  hr
  echo "Tip: set DOMAIN_ROOT=my.tld  EXPECT_IP=1.2.3.4  WATCH_SEC=5 for continuous monitoring."
}

if [[ "$WATCH_SEC" -gt 0 ]]; then
  while :; do clear; run_once; sleep "$WATCH_SEC"; done
else
  run_once
fi
