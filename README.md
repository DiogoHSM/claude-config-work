# claude-config-work

Claude Code plugin with work-oriented session rituals, guardrails, hook-based safety, and lazy-loaded project documentation.

## What it ships

- **Commands**: `/start`, `/end-session`, `/cnp`, `/todo-add`, `/todo-list`
- **Hooks**:
  - `SessionStart` — runs `check-context.sh`, surfaces active cloud/CLI context
  - `PreToolUse / Bash` — blocks destructive commands when active context diverges from `INFRASTRUCTURE.md`
  - `PreToolUse / Edit|Write` — injects the relevant `.claude/docs/*.md` before sensitive file edits
  - `PostToolUse / Bash` — reminds Claude to update docs/memory/Linear after a `git commit`
- **Templates** for `CLAUDE.md`, `GUARDRAILS.md`, and all standard `.claude/docs/*.md` files
- **Provider-agnostic context validator** supporting AWS, GCP, Azure, GitHub, Cloudflare, Fly, Vercel, Firebase, Supabase — extensible via the `<!-- CHECK-CONTEXT -->` block in `INFRASTRUCTURE.md`

## Install

Add this repo as a Claude Code marketplace and install the plugin:

```bash
/plugin marketplace add <git-url-or-local-path>
/plugin install claude-config-work
```

Or for local dev, point Claude Code at this directory.

## Enable per project

In a project's `.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "claude-config-work@<marketplace>": true
  }
}
```

## Provider configuration per project

Drop a `<!-- CHECK-CONTEXT -->` block into `.claude/docs/INFRASTRUCTURE.md`:

```markdown
<!-- CHECK-CONTEXT
aws=123456789012
gh=my-org
-->
```

`check-context.sh` will validate active CLI context against these values at session start and before destructive commands.

## Supported providers (out of the box)

Cloud & platform: `aws`, `gcloud`, `az`, `vercel`, `firebase`, `gh`, `supabase`, `cloudflare`, `fly`.
Data stack: `snowflake`, `dbt`, `dagster`.

Adding a new one: edit `scripts/check-context.sh` and add a `check_<name>` function, then wire it into the `case` dispatcher.
