# clean-task (Codex)

## Task: Clean up a task's worktrees and branches

### Input
- TASK_ID (required)
- --keep-branch flag (optional)

### Instructions

1. Load repo registry from ~/.ai-dev/repo-registry.json.
2. For each repo:
   - Check if ~/task_workspaces/${TASK_ID}-${repo.name} exists.
   - If yes, check for uncommitted changes with git -C <worktree> status --porcelain.
   - If dirty, warn user and ask to force remove.
   - Run git -C <repo.path> worktree remove <worktree-path>.
3. If --keep-branch is NOT set:
   - Delete local branch task/${TASK_ID} in each repo.
4. Run git worktree prune in each base repo.
5. Print cleanup summary.

### Rules
- Never force remove dirty worktrees without confirmation.
- Skip repos where worktree doesn't exist.
