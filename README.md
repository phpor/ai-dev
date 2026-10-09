# ai-dev

Task-first AI coding plugin for Claude Code & Codex CLI.

One task = one worktree + one branch + one isolated sub-agent session.

## Install

### Claude Code
```bash
git clone https://github.com/phpor/ai-dev.git ~/.claude/ai-dev
ln -s ~/.claude/ai-dev/claude/commands/*.md ~/.claude/commands/
```

### Codex CLI
```bash
git clone https://github.com/phpor/ai-dev.git ~/.codex/ai-dev
cp ~/.codex/ai-dev/codex/commands/*.md ~/.codex/commands/
```

## Commands
| Command | Description |
|---|---|
| /new-task <desc> | Create worktree + branch + spawn sub-agent |
| /list-tasks | List all active tasks |
| /resume-task <id> | Resume an existing task |
| /clean-task <id> [--keep-branch] | Clean up worktrees and branches |

## Setup
1. Copy shared/repo-registry.json.example to ~/.ai-dev/repo-registry.json
2. Edit with your repos
3. Clone base repos to ~/repos/

MIT License
