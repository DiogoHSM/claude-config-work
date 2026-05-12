---
description: Capture a new idea or task into the project backlog
argument-hint: <idea or task description>
---

The user provided this idea: $ARGUMENTS

Run the steps:

1. **Interpretation**: read and interpret the idea. Identify the main goal and the value delivered.

2. **Issue proposal**: decide whether it should be 1 issue or split into multiple. For each proposed issue, present:
   - **Title**: short and descriptive
   - **Description**: what needs to be done and why
   - **Priority**: Urgent / High / Normal / Low
   - If multiple issues: briefly explain the split criterion and ask the user whether they prefer:
     - **Independent issues**: each at the same backlog level
     - **Parent + sub-issues**: one parent representing the epic, others as children

3. **Confirmation**: present the proposal and wait for confirmation or adjustments. The user can approve everything, edit titles/descriptions/priorities, remove issues, or change the structure (independent vs sub-issues).

4. **Creation**: after confirmation, create the issues in the Linear project bound in project memory (`.claude/memory/linear.md`).
   - For parent + sub-issues: create the parent first, then the children using the parent's `parentId`.
   - If there's no Linear binding, tell the user and ask whether to bind before continuing.
   - If the user doesn't want to bind now, record the idea in `.claude/TODO.md` so it isn't lost.

5. **Result**: confirm the created issues with their identifiers (e.g. `TEAM-42`) and links.
