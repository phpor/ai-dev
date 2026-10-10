---
name: task-new
description: Create a new task-isolated worktree, branch, and spawn a sub-agent for development
---

# /task-new

Create an isolated worktree + branch for a new task and spawn a sub-agent to do the work.

## Instructions

You are the main orchestrator. Set up an isolated task environment and delegate to sub-agents.

### Step 1: Parse task and identify repos

1. Read `~/.ai-dev/repo-registry.json`. If missing, tell user to copy from `${CLAUDE_PLUGIN_ROOT}/shared/repo-registry.json.example` first.
2. Match task description against repo keywords. Present matched repos for confirmation.
3. If no repos match, ask user to specify which repos to use.

### Step 2: Generate task identity

- `TASK_ID` = `task-YYYYMMDD-XXXXXX` (6 random chars)
- `BRANCH_NAME` = `task/${TASK_ID}`
- `WORKTREE_ROOT` = `~/task_workspaces`

### Step 3: Set up each matched repo

For each repo:
1. `cd` to base repo path
2. `git checkout default_branch && git pull origin default_branch`
3. `git checkout -b ${BRANCH_NAME}` (abort if already exists)
4. `git worktree add ~/task_workspaces/${TASK_ID}-${repo.name} ${BRANCH_NAME}`
5. Write `TASK.md` in the worktree with: task ID, branch, repo name, full task description, and sub-agent instructions

### Step 4: Spawn sub-agents

For each worktree, use `/subtask`:

```
/subtask --cwd <absolute-worktree-path> "Read TASK.md. Complete the task. Write SUMMARY.md when done with changes, tests, and cross-repo deps. Do not modify files outside this worktree."
```

### Step 5: Report

Print task ID, branch name, worktree paths, and list of spawned sub-agents.

### Rules

- NEVER modify files in base repos under `~/repos/`.
- Sub-agents communicate via files only (TASK.md in, SUMMARY.md out).
- After spawning, wait for sub-agents to report via SUMMARY.md.
