---
name: task-list
description: List all active tasks, their worktrees, and status
---

# /task-list

Show all active tasks and their worktree status.

A single task may span multiple repos. All worktrees belonging to the same task share the same TASK_ID prefix and are grouped together — they show as ONE task, not N separate tasks.

## Instructions

1. Scan `~/task_workspaces/` for directories matching `*-YYYYMMDD-XXXXXX-*` (the TASK_ID pattern: `<summary>-<date>-<random6>-<repo-name>`).
2. Extract the TASK_ID prefix (everything before the last `-<repo-name>`) and group worktrees by it.
3. For each task (group):
   - List all repos/worktrees involved
   - Check git status per worktree (clean / modified / untracked)
   - Check if `SUMMARY.md` exists in each worktree (sub-agent finished vs still running)
   - Get last modified time
   - Overall status: `running` if any worktree lacks SUMMARY.md, `done` otherwise
4. Print as a table grouped by task, sorted by most recent.
5. If `~/task_workspaces/` doesn't exist, say "No active tasks found."

## Output format

```
TASK ID                                    REPOS           STATUS     SUMMARY
----------------------------------------------------------------------------------
login-pwd-20261010-a1b2c3                  user-service    done       ready
                                           auth-common     running    -
fix-timeout-20261010-b2c3d4                api-gateway     done       ready
```

Each block = one task. Indented repo rows under it = the worktrees of that task.
