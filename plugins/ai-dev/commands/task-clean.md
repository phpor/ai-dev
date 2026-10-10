---
name: task-clean
description: Clean up a task's worktrees and optionally delete its branches
---

# /task-clean

Remove all worktrees for a task (across all repos), optionally delete the task branches.

## Usage

```
/task-clean <TASK_ID> [--keep-branch]
```

`TASK_ID` is the short form shown by `/task-list`, e.g. `login-pwd-20261010-a1b2c3`.

## Instructions

1. Parse `TASK_ID` (required) and `--keep-branch` flag.
2. Load repo registry from `~/.ai-dev/repo-registry.json`.
3. For each repo in the registry:
   - Check if a worktree exists at `~/task_workspaces/${TASK_ID}-${repo.name}`
   - If not, skip silently
   - If dirty (uncommitted changes), warn user and ask to force remove
   - Run `git worktree remove` (with `--force` if confirmed)
   - If `--keep-branch` is NOT set:
     - Find the branch: `git -C <base-repo> branch --list "*${TASK_ID}"`
     - Delete it with `git branch -D <branch-name>`
4. Run `git worktree prune` in each base repo.
5. Print summary: removed worktrees per repo, deleted branches, skipped repos.

## Rules

- Cleans ALL repos for the given TASK_ID, not just one.
- Never force remove dirty worktrees without user confirmation.
- Skip repos where no worktree exists.
- Branch deletion matches by TASK_ID suffix, so it works regardless of the `<type>/` prefix.
