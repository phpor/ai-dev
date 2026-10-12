# ai-dev

Task-first development plugin for **Claude Code**.

One task = one directory + one branch + one or more worktrees + isolated sub-agents. Tasks can be archived and restored.

## What it does

Instead of running agents directly in your checked-out repo, each task gets:

1. A task directory under `~/task_workspaces/`
2. Its own auto-named semantic branch (`feat/login-pwd-20261010-a1b2c3`)
3. One git worktree per involved repo, as a subdirectory of the task directory
4. A `/subtask` sub-agent running inside each worktree

Your base repos under `~/repos/` stay clean. Completed tasks can be archived to `~/task_archive/` and restored later.

## Install

### In a Claude Code session

```
/plugin marketplace add phpor/ai-dev
/plugin install ai-dev@ai-dev
```

### From shell (CLI)

```bash
# Add the marketplace
claude plugin marketplace add phpor/ai-dev

# Install the plugin
claude plugin install ai-dev@ai-dev

# Verify it's installed
claude plugin list
```

### Enable / disable

```bash
claude plugin enable ai-dev@ai-dev
claude plugin disable ai-dev@ai-dev
```

### Update

```bash
# Pull latest marketplace metadata
claude plugin marketplace update ai-dev

# Update the plugin to the latest version
claude plugin update ai-dev@ai-dev
```

### Use SSH instead of HTTPS

The shorthand `phpor/ai-dev` clones over HTTPS by default. To force SSH, pass the full SSH URL:

```bash
# Remove the HTTPS one first if already added
claude plugin marketplace remove ai-dev

# Add via SSH
claude plugin marketplace add git@github.com:phpor/ai-dev.git

# Then install normally
claude plugin install ai-dev@ai-dev
```

Requirements:
- Your SSH key is added to GitHub and works without a passphrase prompt (`ssh -T git@github.com` succeeds)
- `github.com` is already in `~/.ssh/known_hosts` (first SSH login to GitHub adds it automatically)

### Uninstall

```bash
# Remove the plugin
claude plugin uninstall ai-dev@ai-dev

# Optionally remove the marketplace too
claude plugin marketplace remove ai-dev
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
| `/task-new <desc>` | Create task directory + worktrees + branch + confirm understanding + spawn sub-agents |
| `/task-list` | List active tasks and status; add `--archived` to show archived tasks |
| `/task-resume <task>` | Resume an active task (recover context, cd into worktree) |
| `/task-archive <task>` | Archive a completed task: record commits, clean worktrees, move to `~/task_archive/` |
| `/task-restore <task>` | Restore an archived task: recreate worktrees from recorded commits |

## Usage

```
/task-new Refactor login module, add password strength check
```

Claude will:
1. Match repos from your registry (or discover unknown ones via `glab`)
2. Generate a meaningful task name and semantic branch name (e.g. `feat/login-pwd-20261010-a1b2c3`)
3. Create `~/task_workspaces/task-login-pwd-20261010-a1b2c3/` with `TASK.md` and `archive.json`
4. Create one worktree per repo as a subdirectory
5. Explore code and confirm its understanding with you before starting
6. Spawn `/subtask --cwd <worktree>` for each repo
7. Each sub-agent self-reviews its diff iteratively before writing SUMMARY

## Directory layout

```
~/task_workspaces/
├── task-login-pwd-20261010-a1b2c3/
│   ├── TASK.md
│   ├── archive.json
│   ├── SUMMARY-user-service.md
│   ├── SUMMARY-auth-common.md
│   ├── user-service/          # git worktree
│   └── auth-common/            # git worktree

~/task_archive/
└── task-login-pwd-20261010-a1b2c3/
    ├── TASK.md
    ├── archive.json           # includes commit SHAs, branch info
    └── SUMMARY-*.md
```

## Repo structure

```
ai-dev/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   └── ai-dev/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── commands/
│       │   ├── task-new.md
│       │   ├── task-list.md
│       │   ├── task-resume.md
│       │   ├── task-archive.md
│       │   └── task-restore.md
│       ├── scripts/
│       └── shared/
└── README.md
```

## Codex support

Codex CLI doesn't use the same plugin system. See `plugins/ai-dev/codex/commands/` for equivalent prompts you can paste into your Codex sessions, or add them to your `AGENTS.md`.

## License

MIT
