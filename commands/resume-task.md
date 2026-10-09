---
name: resume-task
description: Resume an existing task by switching to its worktree and recovering context
---

# /resume-task

Resume an existing task worktree and pick up where you left off.

## Usage

```
/resume-task <TASK_ID>
```

## Instructions

1. Find worktrees matching `${TASK_ID}-*` under `~/task_workspaces/`.
2. If none found: tell user "Task not found. Use /list-tasks to see active tasks." and abort.
3. For each worktree:
   - Read `TASK.md` to recover the original task description
   - Read `SUMMARY.md` if it exists (what the sub-agent already completed)
   - Check git status for current uncommitted changes
4. Use the `/cd` built-in to switch the main session to the primary worktree.
5. Present a summary:
   - Original task description
   - What was already done (from SUMMARY.md)
   - Current git status per worktree
   - Suggested next steps
6. Ask user whether to continue in the main session or spawn a fresh `/subtask`.

## Rules

- Do NOT create new branches or worktrees. This resumes an existing task.
- Always recover context from TASK.md and SUMMARY.md before making changes.
