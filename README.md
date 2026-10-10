# ai-dev

Task-first development plugin for **Claude Code**.

One task = one worktree + one branch + one isolated sub-agent. Stop polluting your main repo with parallel changes.

## What it does

Instead of running agents directly in your checked-out repo, each task gets:

1. An isolated `git worktree` under `~/task_workspaces/`
2. Its own auto-named branch (`task/YYYYMMDD-xxxxxx`)
3. A `/subtask` sub-agent running inside that worktree

Your base repos under `~/repos/` stay clean.

## Install

```
/plugin marketplace add phpor/ai-dev
/plugin install ai-dev@ai-dev
```

Then enable it:

```
/plugin enable ai-dev
```

## Setup (one-time)

```bash
# 1. Create config directory
mkdir -p ~/.ai-dev

# 2. Copy the repo registry template
cp ~/.claude/plugins/marketplaces/phpor-ai-dev/plugins/ai-dev/shared/repo-registry.json.example ~/.ai-dev/repo-registry.json

# 3. Edit ~/.ai-dev/repo-registry.json with your actual repos
```

```json
{
  "workspace_root": "~/task_workspaces",
  "repos_root": "~/repos",
  "repos": [
    {
      "name": "user-service",
      "path": "~/repos/user-service",
      "default_branch": "master",
      "keywords": ["登录", "用户", "user", "login"]
    },
    {
      "name": "auth-common",
      "path": "~/repos/auth-common",
      "default_branch": "master",
      "keywords": ["鉴权", "jwt", "token", "auth"]
    }
  ]
}
```

```bash
# 4. Clone your base repos (only once, never edit directly here)
mkdir -p ~/repos && cd ~/repos
git clone git@github.com:your-org/user-service.git
git clone git@github.com:your-org/auth-common.git
```

## Commands

| Command | Description |
|---|---|
| `/task-new <desc>` | Create worktree + branch + spawn sub-agent |
| `/task-list` | List all active tasks and their status |
| `/task-resume <id>` | Resume an existing task worktree |
| `/task-clean <id> [--keep-branch]` | Remove worktrees and branches |

## Usage

```
/task-new Refactor login module, add password strength check
```

Claude will:
1. Match repos from your registry
2. Generate a task ID like `task-20261010-a1b2c3`
3. Pull latest master for each repo
4. Create `task/<task-id>` branches
5. Create worktrees under `~/task_workspaces/`
6. Write `TASK.md` in each worktree
7. Spawn `/subtask --cwd <worktree>` for each repo

## Repo structure

```
ai-dev/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace index
├── plugins/
│   └── ai-dev/                    # The actual plugin
│       ├── .claude-plugin/
│       │   └── plugin.json         # Plugin manifest
│       ├── commands/               # Slash commands
│       │   ├── task-new.md
│       │   ├── task-clean.md
│       │   ├── task-list.md
│       │   └── task-resume.md
│       ├── scripts/
│       └── shared/
└── README.md
```

## Codex support

Codex CLI doesn't use the same plugin system. See `plugins/ai-dev/codex/commands/` for equivalent prompts you can paste into your Codex sessions, or add them to your `AGENTS.md`.

## License

MIT
