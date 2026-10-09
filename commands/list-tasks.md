---
name: list-tasks
description: List all active tasks, their worktrees, and status
---

# /list-tasks

Show all active tasks and their worktree status.

## Instructions

1. Scan `~/task_workspaces/` for directories matching `task-YYYYMMDD-*`.
2. Group by task ID (extract from directory prefix).
3. For each task:
   - List repos/worktrees involved
   - Check git status per worktree (clean / modified / untracked)
   - Check if `SUMMARY.md` exists (sub-agent finished vs still running)
   - Get last modified time
4. Print as a table sorted by most recent.
5. If `~/task_workspaces/` doesn't exist, say "No active tasks found."
