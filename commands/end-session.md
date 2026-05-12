---
description: Session end ritual — review changes, update docs/guardrails/Linear/memory, commit and push
---

Run the session-end ritual in order.

**Quick summary**:
1. Review changes
2. Update docs and guardrails
3. Update Linear / backlog
4. Update memory
5. Commit and push

---

1. **Session review**: run `git diff HEAD` and `git status` to understand what changed. Internally list: modified files, new files, added dependencies, created/removed routes or components.

2. **Update docs and guardrails (driven by `git diff`)**:
   - Run `git diff --name-only` to see files touched this session.
   - Consult `.claude/GUARDRAILS.md` — it maps "when touching X, update Y". For each changed file, identify the related doc(s) and update **only** those.
   - If guardrails don't map it, use judgment:
     - Structural change (new component, route, integration) → `ARCHITECTURE.md`
     - New dependency → `STACK.md`
     - Tech decision → `DECISIONS.md` (ADR format)
     - New env var → `SECRETS.md`
     - New cloud service / infra change → `INFRASTRUCTURE.md`
   - If an **essential** doc doesn't exist yet and the session touched its topic, create it now from `${CLAUDE_PLUGIN_ROOT}/templates/docs/<NAME>.md`.
   - If `GUARDRAILS.md` is stale (doc created/removed, new risk area discovered), update it.
   - Don't ask — just update what's pertinent to the diff.

3. **Update project CLAUDE.md**: if structural changes happened (new files, folders, dependencies, routes), update the Update history and any new convention.

4. **Linear**: if the project is bound to Linear:
   - Close issues resolved this session.
   - Update status of in-progress issues.
   - Create new issues for work discovered this session that isn't in the backlog.
   - Any idea or feature discussed but not implemented becomes a backlog issue.
   - If not bound: update `.claude/TODO.md` marking what was completed and adding what was discovered.

5. **Memory**: persist what was learned.

   **Project memory** (`.claude/memory/`): decisions, patterns, and context specific to this project.
   - Update existing files or create new ones by type (user, feedback, project, reference).
   - Update `.claude/memory/MEMORY.md` if new files were created.
   - If the repo is public and `.claude/memory/` is gitignored, memory stays local — tell the user.

   **Global memory** (cross-project preferences/feedback): write to `~/.claude/memory/`.

6. **Commit and push**: if there are uncommitted changes:
   - Run `git status` and `git diff` (staged and unstaged). Show a summary of what will be committed.
   - Read `git log` to follow project commit style. Propose a clear, concise message.
   - Present the proposed message and wait for confirmation.
   - Commit with the confirmed message (via heredoc, never `--no-verify`).
   - Push to the remote. If the branch has no upstream, use `git push -u origin <branch>`.

7. **Summary**: report what was updated (docs, Linear, memory, commit). One line per item. No redundancy.
