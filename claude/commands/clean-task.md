# Command: /clean-task
# Description: Clean up a task's worktrees and optionally delete its branch
# Usage: /clean-task <TASK_ID> [--keep-branch]

## Instructions

1. Parse TASK_ID (required) and --keep-branch flag.
2. Load repo registry from ~/.ai-dev/repo-registry.json.
3. For each repo:
   - Check if worktree exists at ~/task_workspaces/${TASK_ID}-${repo.name}
   - If dirty, warn and ask to force remove
   - git worktree remove
   - If not --keep-branch, delete local branch task/${TASK_ID}
4. Run git worktree prune in each base repo.
5. Print summary.

### Rules
- Never force remove dirty worktrees without confirmation.
- Skip repos where worktree doesn't exist.
