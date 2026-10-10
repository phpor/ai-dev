---
name: task-clean
description: Clean up a task's worktrees and optionally delete its branches
---

# /task-clean

Remove all worktrees for a task (across all repos), optionally delete the task branches, and remove the task directory.

## Usage

```
/task-clean <task-dir> [--keep-branch]
```

`task-dir` is the task directory name shown by `/task-list`, e.g. `task-login-pwd-20261010-a1b2c3` (or just the suffix `login-pwd-20261010-a1b2c3`).

## Instructions

1. Resolve the task directory:
   - If input starts with `task-`, look for `~/task_workspaces/<input>`
   - Otherwise, look for `~/task_workspaces/task-<input>`
2. If not found: "Task not found. Use /task-list to see active tasks."
3. Read `TASK.md` in the task directory to get the branch name and list of repos.
4. For each subdirectory in the task directory (excluding `TASK.md`):
   - Check if it's dirty (uncommitted changes)
   - If dirty, warn user and ask to force remove
   - Run `git worktree remove` (with `--force` if confirmed)
5. If `--keep-branch` is NOT set:
   - For each base repo (from registry or inferred from worktree remote):
     - Delete the branch: `git -C <base-repo> branch -D <branch-name>`
6. Run `git worktree prune` in each base repo.
7. Remove the now-empty task directory: `rmdir ~/task_workspaces/<task-dir>`
8. Print summary: removed worktrees per repo, deleted branches, skipped repos.

## Rules

- Cleans ALL repos in the task directory, not just one.
- Never force remove dirty worktrees without user confirmation.
- Always run `git worktree remove` before deleting the task directory — never `rm -rf` directly, or base repo metadata will be left behind.
- Branch name comes from `TASK.md`, not guessed.
