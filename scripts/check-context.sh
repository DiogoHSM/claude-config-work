#!/usr/bin/env bash
# check-context.sh — connectivity check + active-context validation against INFRASTRUCTURE.md
#
# Output, one line per provider:
#   ✅ provider: active-value
#   ⚠️  provider: not-authenticated (or error)
#   🔴 provider: active-value (expected: expected-value)
#
# Validation:
#   If the project has .claude/docs/INFRASTRUCTURE.md, the script looks for a block:
#
#     <!-- CHECK-CONTEXT
#     aws=123456789012
#     gcloud=my-project-123
#     gh=my-org
#     az=My Subscription
#     cloudflare=my-account
#     -->
#
#   Each `provider=value` line is an expected value. Providers not listed only get
#   a connectivity check, no value comparison.
#
# Usage: bash check-context.sh [project-dir]

set -uo pipefail

project_dir="${1:-$PWD}"
infra_file="${project_dir}/.claude/docs/INFRASTRUCTURE.md"

has_cli() { command -v "$1" >/dev/null 2>&1; }

# Read expected value from the CHECK-CONTEXT block
expected_for() {
  local key="$1"
  [ ! -f "${infra_file}" ] && return
  awk -v k="$key" '
    /<!-- CHECK-CONTEXT/ { if ($0 ~ /-->/) next; in_block=1; next }
    /-->/ && in_block { in_block=0; next }
    in_block {
      n = index($0, "=")
      if (n > 0) {
        key = substr($0, 1, n-1)
        val = substr($0, n+1)
        gsub(/^[ \t]+|[ \t]+$/, "", key)
        gsub(/^[ \t]+|[ \t]+$/, "", val)
        if (key == k) { print val; exit }
      }
    }
  ' "${infra_file}"
}

# Detect relevant providers (from repo files and from CHECK-CONTEXT block keys)
detect_providers() {
  local list=""
  # AWS signals
  { [ -f "${project_dir}/samconfig.toml" ] || [ -f "${project_dir}/serverless.yml" ] || [ -f "${project_dir}/cdk.json" ] || [ -d "${project_dir}/.aws-sam" ] || ls "${project_dir}"/*.tf >/dev/null 2>&1; } && list="$list aws"
  # GCP signals
  { [ -f "${project_dir}/app.yaml" ] || [ -f "${project_dir}/cloudbuild.yaml" ]; } && list="$list gcloud"
  # Other clouds and platforms
  [ -f "${project_dir}/firebase.json" ] && list="$list firebase"
  [ -f "${project_dir}/vercel.json" ] && list="$list vercel"
  [ -d "${project_dir}/supabase" ] && list="$list supabase"
  [ -d "${project_dir}/.github/workflows" ] && list="$list gh"
  { [ -f "${project_dir}/wrangler.toml" ] || [ -f "${project_dir}/wrangler.jsonc" ]; } && list="$list cloudflare"
  [ -f "${project_dir}/fly.toml" ] && list="$list fly"
  # Data stack signals
  [ -f "${project_dir}/dbt_project.yml" ] && list="$list dbt"
  { [ -f "${project_dir}/dagster.yaml" ] || [ -f "${project_dir}/dagster_cloud.yaml" ] || [ -f "${project_dir}/workspace.yaml" ]; } && list="$list dagster"
  # Snowflake: usually only declared via CHECK-CONTEXT; soft signal if dbt project mentions it
  grep -rqIE 'type:[[:space:]]*snowflake' "${project_dir}"/profiles.yml "${project_dir}"/.dbt/profiles.yml 2>/dev/null && list="$list snowflake"

  # Add providers declared in the CHECK-CONTEXT block
  if [ -f "${infra_file}" ]; then
    local keys
    keys=$(awk '
      /<!-- CHECK-CONTEXT/ { if ($0 ~ /-->/) next; in_block=1; next }
      /-->/ && in_block { in_block=0; next }
      in_block {
        n = index($0, "=")
        if (n > 0) {
          key = substr($0, 1, n-1)
          gsub(/^[ \t]+|[ \t]+$/, "", key)
          if (key !~ /^#/) print key
        }
      }
    ' "${infra_file}")
    for k in $keys; do list="$list $k"; done
  fi

  echo "$list" | tr ' ' '\n' | awk 'NF && !seen[$0]++'
}

compare_active() {
  local provider="$1" active="$2"
  local expected
  expected=$(expected_for "$provider")
  if [ -n "$expected" ] && [ "$active" != "$expected" ]; then
    printf '🔴 %s: %s (expected: %s)\n' "$provider" "$active" "$expected"
  else
    printf '✅ %s: %s\n' "$provider" "$active"
  fi
}

check_aws() {
  has_cli aws || { echo "⚠️  aws: CLI not installed"; return; }
  local active
  active=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
  [ -z "$active" ] && { echo "⚠️  aws: not authenticated (run 'aws sso login' or 'aws configure')"; return; }
  compare_active aws "$active"
}

check_gcloud() {
  has_cli gcloud || { echo "⚠️  gcloud: CLI not installed"; return; }
  local active
  active=$(gcloud config get-value project 2>/dev/null | tr -d '[:space:]')
  [ -z "$active" ] && { echo "⚠️  gcloud: not authenticated (run 'gcloud auth login')"; return; }
  compare_active gcloud "$active"
}

check_az() {
  has_cli az || { echo "⚠️  az: CLI not installed"; return; }
  local active
  active=$(az account show --query name -o tsv 2>/dev/null)
  [ -z "$active" ] && { echo "⚠️  az: not authenticated (run 'az login')"; return; }
  compare_active az "$active"
}

check_vercel() {
  has_cli vercel || { echo "⚠️  vercel: CLI not installed"; return; }
  local active
  active=$(vercel whoami 2>/dev/null | tail -1 | tr -d '[:space:]')
  [ -z "$active" ] && { echo "⚠️  vercel: not authenticated (run 'vercel login')"; return; }
  compare_active vercel "$active"
}

check_firebase() {
  has_cli firebase || { echo "⚠️  firebase: CLI not installed"; return; }
  local active
  active=$(cd "${project_dir}" && firebase use 2>/dev/null | head -1 | awk '{print $NF}')
  [ -z "$active" ] && { echo "⚠️  firebase: no active project"; return; }
  compare_active firebase "$active"
}

check_gh() {
  has_cli gh || { echo "⚠️  gh: CLI not installed"; return; }
  if ! gh auth status >/dev/null 2>&1; then
    echo "⚠️  gh: not authenticated (run 'gh auth login')"
    return
  fi
  local active
  active=$(gh api user --jq .login 2>/dev/null)
  if [ -n "$active" ]; then
    compare_active gh "$active"
  else
    echo "✅ gh: authenticated"
  fi
}

check_supabase() {
  if has_cli supabase; then
    echo "ℹ️  supabase: CLI available (validate org/project via MCP)"
  else
    echo "⚠️  supabase: CLI not installed"
  fi
}

check_cloudflare() {
  has_cli wrangler || { echo "⚠️  cloudflare: wrangler not installed"; return; }
  local active
  active=$(wrangler whoami 2>/dev/null | grep -oE '[[:alnum:]._-]+@[[:alnum:].-]+' | head -1)
  [ -z "$active" ] && { echo "⚠️  cloudflare: not authenticated"; return; }
  compare_active cloudflare "$active"
}

check_fly() {
  has_cli fly || { echo "⚠️  fly: CLI not installed"; return; }
  if fly auth whoami >/dev/null 2>&1; then
    echo "✅ fly: authenticated"
  else
    echo "⚠️  fly: not authenticated"
  fi
}

check_snowflake() {
  has_cli snow || { echo "⚠️  snowflake: 'snow' CLI not installed"; return; }
  local active
  # Default connection name from `snow connection list` (marked with 'true' in is_default)
  active=$(snow connection list --format json 2>/dev/null | /usr/bin/python3 -c 'import json,sys
try:
    data=json.load(sys.stdin)
    for c in data:
        if c.get("is_default") in (True,"true","True"):
            print(c.get("connection_name") or c.get("name") or "")
            break
except Exception: pass' 2>/dev/null)
  [ -z "$active" ] && { echo "⚠️  snowflake: no default connection (run 'snow connection add')"; return; }
  compare_active snowflake "$active"
}

check_dbt() {
  has_cli dbt || { echo "⚠️  dbt: CLI not installed"; return; }
  local profile target
  if [ -f "${project_dir}/dbt_project.yml" ]; then
    profile=$(awk -F: '/^[[:space:]]*profile:/ {gsub(/[[:space:]"'\'']/,"",$2); print $2; exit}' "${project_dir}/dbt_project.yml")
    target=$(awk -F: '/^[[:space:]]*target:/ {gsub(/[[:space:]"'\'']/,"",$2); print $2; exit}' "${project_dir}/dbt_project.yml")
  fi
  local active="${profile:-?}/${target:-?}"
  compare_active dbt "$active"
}

check_dagster() {
  if has_cli dagster-cloud; then
    local org
    org=$(dagster-cloud config view 2>/dev/null | awk -F: '/organization/ {gsub(/[[:space:]"'\'']/,"",$2); print $2; exit}')
    if [ -n "$org" ]; then
      compare_active dagster "$org"
    else
      echo "⚠️  dagster: dagster-cloud installed but no organization configured"
    fi
  elif has_cli dagster; then
    echo "ℹ️  dagster: OSS CLI available (no cloud context to validate)"
  else
    echo "⚠️  dagster: CLI not installed"
  fi
}

providers=$(detect_providers)

if [ -z "$providers" ]; then
  echo "ℹ️  No external providers detected for this project."
  exit 0
fi

for p in $providers; do
  ( case "$p" in
      aws)         check_aws ;;
      gcloud)      check_gcloud ;;
      az|azure)    check_az ;;
      vercel)      check_vercel ;;
      firebase)    check_firebase ;;
      gh|github)   check_gh ;;
      supabase)    check_supabase ;;
      cloudflare)  check_cloudflare ;;
      fly|flyio)   check_fly ;;
      snowflake|sf) check_snowflake ;;
      dbt)         check_dbt ;;
      dagster)     check_dagster ;;
      *)           echo "ℹ️  $p: provider not recognized by this script" ;;
    esac ) &
done
wait
