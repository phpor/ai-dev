# Command: /list-tasks
# Description: List all active tasks and worktree status
# Usage: /list-tasks

## Instructions

1. Scan ~/task_workspaces/ for task-YYYYMMDD-* directories.
2. Group by task ID.
3. For each task: list repos, check git status, check if SUMMARY.md exists.
4. Print as a table sorted by most recent.
5. If no workspaces dir, say "No active tasks found."
