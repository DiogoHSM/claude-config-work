---
description: One-shot commit and push flow
---

Run the one-shot commit-and-push flow:

1. **Review**: run `git status` and `git diff` (staged and unstaged). Show a summary of what will be committed.

2. **Message**: read `git log` to follow project commit style. Propose a clear, concise message focused on the "why" of the change.

3. **Confirmation**: present the proposed message and wait for confirmation or edits before proceeding.

4. **Commit**: commit with the confirmed message. Always pass the message via heredoc. Never use `--no-verify`.

5. **Push**: push to the remote (`git push`). If the branch has no upstream, use `git push -u origin <branch>`.

6. **Post-commit** (after a successful commit):
   - Check whether structural changes happened (new files, folders, dependencies, routes, etc.). If so, update the project `CLAUDE.md` and relevant docs in `.claude/docs/`.
   - Update relevant memory files in `.claude/memory/`.
   - If the project is bound to Linear: review open issues and close/update the ones resolved by this commit.
   - Briefly report what was updated. Don't ask — just do it.

> For a full session wrap-up with docs/Linear/memory review, use `/end-session`.
