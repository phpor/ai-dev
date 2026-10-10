---
name: task-list
description: List all active tasks, their worktrees, and status
---

# /task-list

Show all active tasks and their worktree status.

Each task is a directory under `~/task_workspaces/` named `task-<summary>-<date>-<random6>`. Inside it, each subdirectory (except `TASK.md` and `SUMMARY-*.md`) is a git worktree for one repo.

## Instructions

1. List all directories directly under `~/task_workspaces/` starting with `task-`.
2. If none, say "No active tasks found."
3. For each task directory:
   - Read `TASK.md` at the root of the task directory (get branch name, description)
   - List subdirectories (each is a repo worktree)
   - For each worktree:
     - Check git status (clean / modified / untracked)
     - Check if `SUMMARY-<repo-name>.md` exists at the task root (sub-agent finished vs still running)
   - Overall status: `running` if any repo lacks its SUMMARY file, `done` otherwise
   - Get last modified time
4. Print as a table grouped by task, sorted by most recent.

## Output format

```
TASK DIRECTORY                                  BRANCH                              REPOS           STATUS
--------------------------------------------------------------------------------------------------------------
task-login-pwd-20261010-a1b2c3                  feat/login-pwd-20261010-a1b2c3       user-service    done
                                                                                     auth-common     running
task-fix-timeout-20261010-b2c3d4                fix/timeout-20261010-b2c3d4          api-gateway     done
```

Each block = one task. Indented repo rows under it = the worktrees of that task.
