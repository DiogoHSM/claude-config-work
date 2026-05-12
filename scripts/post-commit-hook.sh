#!/usr/bin/env bash
# post-commit-hook.sh — PostToolUse hook for Bash
#
# After a `git commit` runs via the Bash tool, reminds Claude to update docs,
# memory and backlog. Non-blocking; pure stdout reminder.

set -uo pipefail

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | /usr/bin/python3 -c 'import json,sys
try:
    d = json.load(sys.stdin)
    print(d.get("tool_input", {}).get("command", ""))
except Exception:
    print("")' 2>/dev/null)

if printf '%s' "$COMMAND" | grep -qE "git commit"; then
    echo "SYSTEM REMINDER: a git commit was just made. Please:"
    echo "1. Check whether structural changes happened."
    echo "2. If so, update the project's CLAUDE.md (architecture + Update history)."
    echo "3. Update relevant memory files in .claude/memory/."
    echo "4. Review .claude/TODO.md (or Linear) and close items resolved by this commit."
fi
