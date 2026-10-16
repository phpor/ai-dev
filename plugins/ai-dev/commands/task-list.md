---
name: task-list
description: List active and archived tasks, their worktrees, process status, and status
---

# /task-list

Show all active tasks under `~/task_workspaces/`. Use `/task-list --archived` to see archived tasks under `~/task_archive/`.

## Instructions

1. By default, list active tasks under `~/task_workspaces/`:
   - List directories starting with `task-`.
   - If none, say "No active tasks found."
   - For each task directory:
     - Read `archive.json` for the meaningful task name and branch.
     - If archive.json is missing, fall back to TASK.md.
     - List subdirectories (each is a repo worktree).
     - For each worktree: check git status (clean / modified / untracked).
     - Check if `SUMMARY-<repo-name>.md` exists (sub-agent done vs running).
     - Overall status: `running` if any repo lacks its SUMMARY, `done` otherwise.
     - **Check process status**: read `processes.json` if it exists. For each recorded PID, check if it's alive with `kill -0 <pid>`. Show running processes with their port.
     - Get last modified time.

2. If `--archived` flag is passed:
   - List directories under `~/task_archive/` starting with `task-`.
   - For each, read `archive.json` for task name, description, archived_at, and per-repo commit SHAs.
   - No worktrees exist for archived tasks — show commit info instead.

3. Print as a table grouped by task, sorted by most recent.

## Output format — active tasks

```
TASK NAME                                    DIRECTORY                          REPOS           STATUS    PROCESSES
---------------------------------------------------------------------------------------------------------------------------
Add password strength validation             task-login-pwd-20261010-a1b2c3     user-service    done      running :8080 (PID 12345)
                                                                                 auth-common     running   —
Fix gateway timeout on retries                task-fix-timeout-20261010-b2c3d4   api-gateway     done      stopped (PID stale)
```

If a task has running processes, note it clearly so the user knows to stop them before archiving.

## Output format — archived tasks (--archived)

```
TASK NAME                                    DIRECTORY                          ARCHIVED           COMMITS
--------------------------------------------------------------------------------------------------------------
Add password strength validation             task-login-pwd-20261010-a1b2c3     2026-10-11         user-service: a1b2c3d
                                                                                                                 auth-common: e3f4g5h
```
