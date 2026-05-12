---
description: Session start ritual — connectivity check, guardrails, docs inventory, memory, Linear, backlog
---

Run the session-start actions in order.

**Quick summary**:
1. Connectivity & active-context check
2. Git sync
3. Guardrails (lazy-loading contract)
4. Docs inventory (no speculative creation)
5. Project CLAUDE.md
6. Memory (lazy)
7. Linear binding
8. Backlog summary

---

0. **Connectivity & active context**: run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/check-context.sh` and show the output to the user.

   The script auto-detects providers (AWS, GCP, Azure, GitHub, Vercel, Firebase, Supabase, Cloudflare, Fly) from repo files (`samconfig.toml`, `cdk.json`, `*.tf`, `vercel.json`, `firebase.json`, `app.yaml`, `.github/workflows/`, etc.) and from the `<!-- CHECK-CONTEXT -->` block in `.claude/docs/INFRASTRUCTURE.md`. For each provider:
   - ✅ active context OK
   - ⚠️ not authenticated or CLI missing — tell the user how to fix, don't block
   - 🔴 **diverging context** — flag prominently and recommend **not running destructive operations** until fixed

   Linear MCP is checked separately (the script doesn't cover MCPs): try a simple call; if it fails, warn and fall back to `.claude/TODO.md`.

1. **Git sync**: run `git fetch --quiet && git status -sb`.
   - If the branch is behind: warn with ⚠️ and recommend `git pull` before continuing.
   - If it's ahead or diverged: also report.
   - Not a git repo or no remote: ignore silently.

2. **Guardrails (lazy-loading contract)**: `.claude/GUARDRAILS.md` is the only file besides `CLAUDE.md` and `MEMORY.md` that is **always loaded**. It's the table telling you which docs to read before touching each area.

   - If `.claude/GUARDRAILS.md` does **not exist**:
     - Read `${CLAUDE_PLUGIN_ROOT}/templates/GUARDRAILS.md`.
     - Copy to `.claude/GUARDRAILS.md` and customize:
       - Replace `[Project Name]` with the real name (from `package.json` or the folder).
       - Set today's date in "Last revised".
       - **Remove rows from the table that don't apply** to this project.
       - Keep only actionable guardrails for this project.
   - If it **exists**: read it for this session and verify coherence with the current `.claude/docs/`. Silently adjust if a listed doc no longer exists or a new important doc lacks a row.
   - **Read GUARDRAILS.md now** — required step. It stays as reference for lazy-loading decisions throughout the session.

3. **Docs (`.claude/docs/`) — on demand**: **Do not create docs speculatively.** Inventory only.

   - List files in `.claude/docs/` (if it exists).
   - If non-standard architecture docs exist (e.g. `ARCHITECTURE.md` at repo root, `docs/stack.md`, `ADR/*.md`): migrate content to `.claude/docs/` with canonical names and remove the old ones.
   - Make sure `.gitignore` contains `.claude/docs/SECRETS.md`. If not, add it.
   - **Do not create placeholder files.** Docs are created **only** when Claude is about to touch the related topic — guardrails will say: "If the doc doesn't exist yet, create it from `${CLAUDE_PLUGIN_ROOT}/templates/docs/<NAME>.md` before continuing".

4. **Project CLAUDE.md**: check whether `CLAUDE.md` exists at project root.
   - If not: read `${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md` and adapt, exploring the project to fill in stack, structure, and conventions.
   - If it exists but is incomplete (no pointers to `.claude/docs/`, no conventions section, no history): complete the missing sections without erasing existing content.

5. **Memory (lazy)**: read **indexes only**, not referenced files.

   **Level 1 — global**: read `~/.claude/memory/MEMORY.md`. If missing, mention briefly and continue.

   **Level 2 — project**: read `.claude/memory/MEMORY.md` in the current directory. If missing, create it empty.

   **Important**: do NOT read files listed in the index during `/start`. They are read **on demand** when a relevant topic comes up.

6. **Linear**: check project memory (`.claude/memory/`) for `linear_project_id`.
   - If already bound: use silently.
   - If not bound: search Linear for projects whose name resembles the repo name (folder or `package.json` `name`). Present candidates and ask which to use. After confirmation, save in `.claude/memory/linear.md` and update `MEMORY.md`.
   - If Linear MCP is unavailable: ignore silently.

7. **Backlog (summary)**: if bound to Linear, fetch **counts and urgent items only**.
   - Ask the MCP: total open issues, priority-1 (urgent) issues, blocking issues.
   - **Don't list** regular issue titles — just mention the count. For urgent/blocking, list ID + short title (one line each).
   - Issue details are read **on demand** when the user asks.
   - If not bound to Linear: read `.claude/TODO.md` and show only the "In progress" section + a count of "Pending".
