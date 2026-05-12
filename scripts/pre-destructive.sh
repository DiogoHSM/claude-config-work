#!/usr/bin/env bash
# pre-destructive.sh — PreToolUse hook for Bash
#
# Reads JSON from stdin: { tool_name, tool_input: { command } }. If the command
# matches destructive/irreversible patterns, validates active context against
# INFRASTRUCTURE.md. On 🔴 divergence, blocks with exit code 2.
#
# Never blocks due to missing CLI or auth — only on explicit divergence.
# Always prints a visible warning.

set -uo pipefail

input=$(cat)
cmd=$(printf '%s' "$input" | /usr/bin/python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("tool_input",{}).get("command",""))' 2>/dev/null)

[ -z "$cmd" ] && exit 0

# Destructive patterns — any match triggers validation
destructive_regex='(^|[^a-zA-Z_])(rm[[:space:]]+(-[a-zA-Z]*[rRf][a-zA-Z]*[[:space:]]+|--recursive|--force)|rm[[:space:]]+-[rRf]+|DROP[[:space:]]+TABLE|DROP[[:space:]]+DATABASE|DROP[[:space:]]+SCHEMA|TRUNCATE[[:space:]]+TABLE|aws[[:space:]]+s3[[:space:]]+rm|aws[[:space:]]+[^|;&]*[[:space:]]+(delete|rm|remove)|gcloud[[:space:]]+[^|;&]*[[:space:]]+delete|az[[:space:]]+[^|;&]*[[:space:]]+delete|supabase[[:space:]]+[^|;&]*[[:space:]]+delete|vercel[[:space:]]+rm|firebase[[:space:]]+[^|;&]*[[:space:]]+delete|terraform[[:space:]]+destroy|kubectl[[:space:]]+delete|snow[[:space:]]+sql[[:space:]]+[^|;&]*(DROP|TRUNCATE|DELETE[[:space:]]+FROM)|dbt[[:space:]]+(seed|run|build|run-operation)[[:space:]]+[^|;&]*(--full-refresh|--target[[:space:]]+prod)|dagster-cloud[[:space:]]+[^|;&]*[[:space:]]+delete|git[[:space:]]+push[[:space:]]+[^|;&]*--force|git[[:space:]]+push[[:space:]]+[^|;&]*-f(\s|$)|git[[:space:]]+reset[[:space:]]+--hard|git[[:space:]]+branch[[:space:]]+-D)'

if ! printf '%s' "$cmd" | grep -qE "$destructive_regex"; then
  exit 0
fi

# Command is destructive — run check-context.sh and look for 🔴
checker="${CLAUDE_PLUGIN_ROOT}/scripts/check-context.sh"
[ ! -x "$checker" ] && exit 0

check_output=$(bash "$checker" "$PWD" 2>/dev/null || true)

if printf '%s' "$check_output" | grep -q '🔴'; then
  printf '🛑 PreToolUse: destructive command BLOCKED.\n\n'
  printf 'Command: %s\n\n' "$cmd"
  printf 'Active context diverges from INFRASTRUCTURE.md:\n'
  printf '%s\n' "$check_output" | grep '🔴' | sed 's/^/  /'
  printf '\nFix the diverging provider context before retrying.\n'
  exit 2
fi

# Context OK — print a visible non-blocking warning
printf '⚠️  Destructive command detected: %s\n' "$cmd"
printf 'Context validated against INFRASTRUCTURE.md — proceeding.\n'
exit 0
