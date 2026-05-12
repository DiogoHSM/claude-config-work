#!/usr/bin/env bash
# doc-inject.sh — PreToolUse hook for Edit|Write
#
# Reads JSON from stdin: { tool_name, tool_input: { file_path } }. If the path
# matches a sensitive pattern, injects the corresponding doc from .claude/docs/
# into stdout — Claude receives it as a system-reminder.
#
# Never blocking. If the doc doesn't exist, tells Claude to create it from the
# template before continuing.

set -uo pipefail

input=$(cat)
file_path=$(printf '%s' "$input" | /usr/bin/python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("tool_input",{}).get("file_path",""))' 2>/dev/null)

[ -z "$file_path" ] && exit 0

project_root=$(git -C "$(dirname "$file_path")" rev-parse --show-toplevel 2>/dev/null || pwd)
docs_dir="$project_root/.claude/docs"
templates_dir="${CLAUDE_PLUGIN_ROOT}/templates/docs"

# Path → docs mapping
docs_to_read=""

case "$file_path" in
  */.github/workflows/*|*/cloudbuild.yaml|*/cloudbuild.yml|*/app.yaml|*/firebase.json|*/vercel.json|*/samconfig.toml|*/serverless.yml|*/cdk.json|*/fly.toml|*/wrangler.toml|*/Dockerfile*|*/docker-compose*.yml|*/docker-compose*.yaml|*.tf|*/terraform/*|*/dagster.yaml|*/dagster_cloud.yaml|*/workspace.yaml)
    docs_to_read="DEPLOYMENT.md INFRASTRUCTURE.md"
    ;;
  */migrations/*|*.sql|*/prisma/schema.prisma|*/schema.rb|*/alembic/*)
    docs_to_read="DECISIONS.md CONSTRAINTS.md"
    ;;
  */dbt_project.yml|*/profiles.yml|*/models/*|*/macros/*|*/seeds/*|*/snapshots/*)
    docs_to_read="ARCHITECTURE.md STACK.md INFRASTRUCTURE.md"
    ;;
  */package.json|*/requirements.txt|*/pyproject.toml|*/go.mod|*/Gemfile|*/Cargo.toml|*/pom.xml|*/build.gradle*)
    docs_to_read="STACK.md"
    ;;
  */.env|*/.env.*)
    docs_to_read="SECRETS.md"
    ;;
  */tailwind.config.*|*/styles/*)
    docs_to_read="UI-UX.md"
    ;;
esac

[ -z "$docs_to_read" ] && exit 0

printf '📎 doc-inject: editing %s\n\n' "$(basename "$file_path")"
printf 'Guardrails point to the docs below. Consult them before proceeding.\n\n'

for doc in $docs_to_read; do
  doc_path="$docs_dir/$doc"
  if [ -f "$doc_path" ]; then
    printf -- '--- %s ---\n' "$doc"
    cat "$doc_path"
    printf '\n'
  else
    printf '⚠️  %s does not exist yet. If this edit needs that knowledge, create it from %s/%s before continuing.\n\n' "$doc" "$templates_dir" "$doc"
  fi
done

exit 0
