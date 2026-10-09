# resume-task (Codex)

## Task: Resume an existing task

### Input
- TASK_ID (required)

### Instructions

1. Find worktrees under ~/task_workspaces/${TASK_ID}-*.
2. If none found, tell user and suggest list-tasks.
3. For each worktree:
   - Read TASK.md for original description
   - Read SUMMARY.md if exists for completed work
   - Check git status
4. Switch main agent's working directory to the primary worktree using /directory.
5. Present summary: original task, completed work, current changes, next steps.
6. Ask user whether to continue in main session or spawn a new sub-agent.

### Rules
- Do NOT create new worktrees or branches.
- Always recover context from TASK.md and SUMMARY.md first.
