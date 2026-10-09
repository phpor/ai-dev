# list-tasks (Codex)

## Task: List all active tasks

### Instructions

1. Scan ~/task_workspaces/ for directories matching task-YYYYMMDD-*.
2. Group by task ID.
3. For each task:
   - List repos involved
   - Check git status per worktree (clean/modified)
   - Check if SUMMARY.md exists (done/running)
   - Get last modified time
4. Print as a table sorted by most recent.

### Rules
- If no task_workspaces directory exists, say "No active tasks."
- Use repo registry to know all possible repos.
