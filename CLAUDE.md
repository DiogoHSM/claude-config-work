# claude-config-work — plugin instructions

These instructions apply to every session where this plugin is enabled.

---

## Project context infrastructure

| File | Location | Purpose |
|---|---|---|
| `CLAUDE.md` | project root | Local context, conventions, pointers |
| `.claude/GUARDRAILS.md` | project root | **Always loaded.** "Before touching X, read Y" table |
| `.claude/docs/*.md` | project root | Technical docs. **Read on demand.** Templates in `${CLAUDE_PLUGIN_ROOT}/templates/docs/` |
| `.claude/memory/` | project root | Project memory (index in `MEMORY.md`) |

`SECRETS.md` must always be in `.gitignore`.

### Standard docs (create on demand, never speculatively)

`PROJECT-SUMMARY` · `ARCHITECTURE` · `STACK` · `DEPLOYMENT` · `CONSTRAINTS` · `DECISIONS` (ADRs) · `SECRETS` · `INFRASTRUCTURE` · `UI-UX`. Templates in `${CLAUDE_PLUGIN_ROOT}/templates/docs/`.

### When to update
- New feature → Linear / `TODO.md` + relevant doc
- Stack/architecture change → `ARCHITECTURE.md` + `STACK.md`
- Environment/CI → `DEPLOYMENT.md` · Tech decision → `DECISIONS.md` (ADR)
- New env var → `SECRETS.md` · Cloud/org → `INFRASTRUCTURE.md` · Design system → `UI-UX.md`

---

## Slash commands

- `/start` — git sync, guardrails, connectivity check, docs, memory, Linear, backlog
- `/end-session` — review, update docs/guardrails, Linear, memory, commit, push
- `/cnp` — one-shot commit & push
- `/todo-add` — capture a new idea/task into the Linear backlog
- `/todo-list` — show backlog and pick an issue to work on

---

## Memory

`MEMORY.md` (global and project) is an **index**. Individual files are read on demand. Types: `user`, `feedback`, `project`, `reference`.

---

## Workflow for non-trivial tasks

1. Plan with `EnterPlanMode`
2. Create a Linear issue + plan in `.claude/plans/`
3. Execute with subagents (`Agent` + `run_in_background`) to preserve context
4. Verify (`tsc --noEmit`, tests, or equivalent)

---

## Preferences

- Short, direct responses. No trailing "here's what I just did" summaries.
- English by default.
- Edit existing files; only create new ones when necessary.
- Do not add comments, docstrings, or types to code that wasn't modified.
- After any `git commit`: if structural changes happened, update the project's `CLAUDE.md` and relevant `.claude/docs/`. Update memory/Linear if applicable. Don't ask.
