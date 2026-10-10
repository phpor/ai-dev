---
name: task-clean
description: Clean up a task's worktrees and optionally delete its branches
---

# /task-clean

Remove worktrees for a completed task, optionally delete the task branches.

## Usage

```
/task-clean <TASK_ID> [--keep-branch]
```

## Instructions

1. Parse `TASK_ID` (required) and `--keep-branch` flag.
2. Load repo registry from `~/.ai-dev/repo-registry.json`.
3. For each repo in the registry:
   - Check if worktree exists at `~/task_workspaces/${TASK_ID}-${repo.name}`
   - If dirty (uncommitted changes), warn user and ask to force remove
   - Run `git worktree remove` (with `--force` if confirmed)
   - If `--keep-branch` is NOT set, delete local branch `task/${TASK_ID}`
4. Run `git worktree prune` in each base repo.
5. Print summary: removed worktrees, deleted branches, skipped repos.

## Rules

- Never force remove dirty worktrees without user confirmation.
- Skip repos where worktree doesn't exist.
