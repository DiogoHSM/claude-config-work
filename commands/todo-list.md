---
description: Show the project backlog and let the user pick an issue to work on
---

Show the project backlog and let the user pick an issue.

Run the steps:

1. **Lookup**: read `linear_project_id` from project memory (`.claude/memory/linear.md`). If there's no binding, tell the user and suggest running `/start`.

2. **List**: fetch open issues for the project from Linear. Show as a table:
   - Identifier (e.g. `TEAM-42`)
   - Title
   - Priority (🔴 Urgent / 🟠 High / 🟡 Normal / 🔵 Low / ⚪ None)
   - Status

3. **Selection**: ask whether the user wants to work on a specific issue. Accept the identifier or the row number.

4. **Context**: if the user picks one:
   - Show title, full description, priority, status
   - Analyze the project code and suggest where to start (relevant files, initial approach)
   - Ask whether you can start implementing
