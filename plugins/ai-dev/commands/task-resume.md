---
name: task-resume
description: Resume an existing task by switching to its worktree and recovering context
---

# /task-resume

Resume an existing task (all its worktrees across repos) and pick up where you left off.

## Usage

```
/task-resume <task-dir>
```

`task-dir` is the task directory name shown by `/task-list`, e.g. `task-login-pwd-20261010-a1b2c3` (or just the suffix `login-pwd-20261010-a1b2c3`).

## Instructions

1. Resolve the task directory:
   - If input starts with `task-`, look for `~/task_workspaces/<input>`
   - Otherwise, look for `~/task_workspaces/task-<input>`
2. If not found: tell user "Task not found. Use /task-list to see active tasks." and abort.
3. Read `TASK.md` in the task directory to recover the original task description and branch name.
4. **Read all `PROGRESS-*.md` files** in the task directory (glob `PROGRESS-*.md`). Aggregate them:
   - Count `- [x]` vs `- [ ]` across all progress files
   - Display: "Progress: 5/12 items done (42%)"
   - Group by file (repo), show which repos have pending items
   - List remaining unchecked items as "What's left"
5. For each subdirectory (repo worktree):
   - Read `SUMMARY-<repo-name>.md` at the task root if it exists (what the sub-agent already completed)
   - Check git status for current uncommitted changes
6. Use the `/cd` built-in to switch the main session to the primary worktree (first repo found, or ask user which one).
7. Present a summary:
   - Original task description (from TASK.md)
   - **Progress checklist (from all PROGRESS-*.md files)** — done items struck through, pending items highlighted, grouped by repo
   - List of repos/worktrees involved
   - What was already done (from each SUMMARY-<repo>.md)
   - Current git status per worktree
   - Suggested next steps (first unchecked item)
8. Ask user whether to continue in the main session or spawn a fresh `/subtask`.

## Rules

- Do NOT create new branches or worktrees. This resumes an existing task.
- Always recover context from `TASK.md`, all `PROGRESS-*.md`, and `SUMMARY-<repo>.md` (all at task root) before making changes.
- A task may span multiple repos — report status for all of them.
