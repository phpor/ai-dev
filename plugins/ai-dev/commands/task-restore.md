---
name: task-restore
description: Restore an archived task back to active workspaces with worktrees from recorded commits
---

# /task-restore

Restore a previously archived task: recreate worktrees from recorded commits and move the task directory back to `~/task_workspaces/`.

## Usage

```
/task-restore <task-dir>
```

`task-dir` is the task directory name or its suffix, e.g. `task-login-pwd-20261010-a1b2c3` or `login-pwd-20261010-a1b2c3`.

## Instructions

1. **Locate the archived task**:
   - If input starts with `task-`, look for `~/task_archive/<input>`
   - Otherwise, look for `~/task_archive/task-<input>`
   - If not found in archive, check `~/task_workspaces/` — if it's already active, say "This task is already active."
   - If not found anywhere: "Task not found. Use /task-list to see active tasks and /task-list --archived to see archived."

2. **Read `archive.json`** to get: branch name, repos, base paths, last commit SHAs, and whether branches were deleted.

3. **Verify commits exist in base repos**:
   - For each repo, run `git -C <base-repo> cat-file -t <last_commit>`.
   - If a commit is missing (e.g. after garbage collection):
     - Warn the user: "Commit <sha> for <repo> no longer exists in the base repo. This worktree cannot be restored."
     - Ask whether to skip that repo or abort.

4. **Recreate branches and worktrees** for each repo:
   - If the branch still exists in the base repo:
     ```bash
     git -C <base-repo> worktree add ~/task_workspaces/<task-dir>/<repo-name> <branch-name>
     ```
   - If the branch was deleted during archive:
     ```bash
     git -C <base-repo> checkout -b <branch-name> <last_commit>
     git -C <base-repo> worktree add ~/task_workspaces/<task-dir>/<repo-name> <branch-name>
     ```
   - If the branch exists but points to a different commit:
     - Warn the user and ask: "Branch <branch> exists but is at <current-sha>, archive recorded <archived-sha>. Continue anyway?"

5. **Move the task directory back**:
   ```bash
   mv ~/task_archive/<task-dir> ~/task_workspaces/<task-dir>
   ```

6. **Update archive.json**: set `archived_at` to null, add `restored_at` timestamp.

7. **Present summary**:
   - Task name and description
   - Repos restored with their commit SHAs
   - Any repos that were skipped (missing commits)
   - Use `/cd` to switch to the primary worktree, or ask the user which one.

8. Ask whether to continue working immediately or spawn a fresh `/subtask`.

## Rules

- Never force-overwrite an existing worktree at the same path.
- If base repo has diverged significantly from the recorded commit, warn but do not block — the user decides.
- After restore, the task is active again and shows in `/task-list`.
