# ai-dev

Task-first development plugin for Codex CLI.

## Commands
- new-task <description> - Create worktree + branch + spawn_agent
- list-tasks - Show all active tasks
- resume-task <id> - Resume an existing task
- clean-task <id> [--keep-branch] - Clean up worktrees and branches

## Setup
1. Copy shared/repo-registry.json.example to ~/.ai-dev/repo-registry.json
2. Edit with your repos
3. Clone base repos to ~/repos/
