# ai-dev

Task-first development plugin for Claude Code.

## Commands
- /new-task <description> - Create isolated worktree + branch + spawn sub-agent
- /list-tasks - Show all active tasks and their status
- /resume-task <id> - Resume an existing task worktree
- /clean-task <id> [--keep-branch] - Remove task worktrees and branches

## Setup
1. Copy shared/repo-registry.json.example to ~/.ai-dev/repo-registry.json
2. Edit with your repos
3. Clone base repos to ~/repos/
4. Run /new-task to start
