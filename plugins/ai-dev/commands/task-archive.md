---
name: task-archive
description: Archive a completed task — stop processes, move to ~/task_archive, record commit metadata, clean up worktrees
---

# /task-archive

Archive a task: stop all background processes, record commit metadata, remove worktrees, move the task directory to `~/task_archive/`. The task can be restored later with `/task-restore`.

## Usage

```
/task-archive <task-dir>
```

`task-dir` is the task directory name or its suffix, e.g. `task-login-pwd-20261010-a1b2c3` or `login-pwd-20261010-a1b2c3`.

## Instructions

1. **Resolve the task directory**:
   - If input starts with `task-`, look for `~/task_workspaces/<input>`
   - Otherwise, look for `~/task_workspaces/task-<input>`
   - If not found, check `~/task_archive/` — if it's already archived, say so.
   - If not found anywhere: "Task not found. Use /task-list to see active tasks."

2. **Read `archive.json`** in the task directory to get branch name, repos, and base paths.

3. **Stop all recorded processes**:
   - Read `processes.json` in the task directory (if it exists).
   - For each entry, check if the PID is still alive: `kill -0 <pid> 2>/dev/null`
   - If alive, gracefully stop it: `kill <pid>`, wait 2 seconds, then force kill if still running: `kill -9 <pid>`
   - Also kill any child processes: use `pkill -P <pid>` before/after killing the parent.
   - Record which processes were already dead vs successfully killed.
   - **Fallback**: If `processes.json` is missing or PIDs are stale, search for processes matching the task branch name or known ports:
     ```bash
     # Find processes by port
     lsof -ti:<port> | xargs kill -9 2>/dev/null
     # Or match by command line containing the branch name
     pkill -f "<branch-name>" 2>/dev/null
     ```
   - Archive `processes.json` as `processes.stopped.json` for reference.

4. **Check for dirty worktrees**:
   - For each repo subdirectory, run `git status --porcelain`.
   - If any worktree has uncommitted changes:
     - List them and ask the user: "This task has uncommitted changes in <repo>. Do you want to (a) commit them before archiving, (b) stash them, or (c) discard them?"
     - Do NOT proceed until resolved.

5. **Record commit metadata** for each repo:
   ```bash
   COMMIT=$(git -C <worktree> rev-parse HEAD)
   # Check if branch is pushed to remote
   git -C <worktree> ls-remote --heads origin <branch> | grep -q <commit>
   ```
   Update `archive.json`:
   - `last_commit`: full commit SHA
   - `pushed_to_remote`: true/false
   - `remote_branch`: remote branch name if pushed
   - `archived_at`: current ISO timestamp
   - `commit_history`: output of `git log --oneline <default-branch>..HEAD` for the repo

6. **Ask about branch handling**:
   - For each repo, ask: "Keep the branch `<branch>` or delete it?"
   - If the user says delete: `git -C <base-repo> branch -D <branch>`
   - If keep: leave it; restore will reuse it.
   - Note the choice in archive.json (`branch_deleted: true/false`).

7. **Remove worktrees**:
   ```bash
   git -C <base-repo> worktree remove <worktree-path>
   ```
   Run `git worktree prune` in each base repo.

8. **Move the task directory to archive**:
   ```bash
   mkdir -p ~/task_archive
   mv ~/task_workspaces/<task-dir> ~/task_archive/<task-dir>
   ```
   The archived directory contains: TASK.md, archive.json, SUMMARY-*.md, processes.stopped.json. No worktrees.

9. **Print summary**: task name, archived location, processes stopped, commits recorded, branches kept/deleted.

## Rules

- ALWAYS stop all processes before removing worktrees — worktree removal will fail if files are locked by running processes.
- NEVER skip the dirty worktree check.
- NEVER `rm -rf` the task directory — always `mv` to archive.
- Always record `last_commit` before removing worktrees.
- If a worktree is on a detached HEAD (no branch), still record the commit SHA.
- If processes.json is missing, use port/branch-name fallback to find and kill leaked processes.
- Archive is a safe operation — no code is lost, only worktrees are cleaned up.
