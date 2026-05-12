#!/usr/bin/env bash
# session-start.sh — SessionStart hook
#
# Runs check-context.sh automatically when a session starts/resumes.
# Output appears in the transcript as session context. Never blocking.

set -uo pipefail

checker="${CLAUDE_PLUGIN_ROOT}/scripts/check-context.sh"
[ ! -x "$checker" ] && exit 0

output=$(bash "$checker" "$PWD" 2>/dev/null || true)
[ -z "$output" ] && exit 0

printf '## Active context (check-context.sh)\n\n'
printf '%s\n' "$output"
exit 0
