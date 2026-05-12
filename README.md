# claude-config-work

Claude Code plugin with work-oriented session rituals, guardrails, hook-based safety, and lazy-loaded project documentation.

## What it ships

- **Commands**: `/work:start`, `/work:end-session`, `/work:cnp`, `/work:todo-add`, `/work:todo-list`
- **Hooks**:
  - `SessionStart` — runs `check-context.sh`, surfaces active cloud/CLI context
  - `PreToolUse / Bash` — blocks destructive commands when active context diverges from `INFRASTRUCTURE.md`
  - `PreToolUse / Edit|Write` — injects the relevant `.claude/docs/*.md` before sensitive file edits
  - `PostToolUse / Bash` — reminds Claude to update docs/memory/Linear after a `git commit`
- **Templates** for `CLAUDE.md`, `GUARDRAILS.md`, and all standard `.claude/docs/*.md` files
- **Provider-agnostic context validator** supporting AWS, GCP, Azure, GitHub, Cloudflare, Fly, Vercel, Firebase, Supabase — extensible via the `<!-- CHECK-CONTEXT -->` block in `INFRASTRUCTURE.md`

## Install

Add this repo as a Claude Code marketplace and install the plugin at **user scope**:

```bash
/plugin marketplace add DiogoHSM/claude-config-work
/plugin install work
```

User-scope install means the plugin is automatically enabled for **every project** on the machine — no per-project setup required.

## Disable for a specific project (opt-out)

If a specific repo shouldn't use this plugin, add to its `.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "work@claude-config-work": false
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
