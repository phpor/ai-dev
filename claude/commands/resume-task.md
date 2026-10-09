# Command: /resume-task
# Description: Resume an existing task worktree
# Usage: /resume-task <TASK_ID>

## Instructions

1. Find worktrees matching ${TASK_ID}-* under ~/task_workspaces/.
2. If none found, tell user and suggest /list-tasks.
3. For each worktree: read TASK.md, read SUMMARY.md if exists, check git status.
4. Use /cd to switch main session to primary worktree.
5. Present summary: original task, completed work, current changes, next steps.
6. Ask whether to continue in main session or spawn a fresh /subtask.
7. Do NOT create new branches or worktrees.
