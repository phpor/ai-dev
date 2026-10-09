# Command: /new-task
# Description: Task-first development - auto-create worktree, branch, spawn sub-agent
# Usage: /new-task <task description>

## Instructions

You are the main orchestrator agent. Set up an isolated task environment and delegate to sub-agents.

### Step 1: Parse task and identify repos

1. Read ~/.ai-dev/repo-registry.json. If missing, tell user to copy from shared/repo-registry.json.example first.
2. Match task description against repo keywords.
3. Present matched repos for user confirmation.

### Step 2: Generate task identity

- TASK_ID = task-YYYYMMDD-XXXXXX (6 random chars)
- BRANCH_NAME = task/${TASK_ID}
- WORKTREE_ROOT = ~/task_workspaces

### Step 3: Set up each matched repo

For each repo:
1. cd to base repo path
2. git checkout default_branch && git pull origin default_branch
3. git checkout -b ${BRANCH_NAME}
4. git worktree add ~/task_workspaces/${TASK_ID}-${repo.name} ${BRANCH_NAME}
5. Write TASK.md in worktree with task details and sub-agent instructions

### Step 4: Spawn sub-agents

For each worktree:
/subtask --cwd <absolute-path> "Read TASK.md. Complete the task. Write SUMMARY.md when done with changes, tests, cross-repo deps. Don't modify files outside this worktree."

### Rules
- Never modify base repos in ~/repos/.
- Abort if branch already exists.
- Sub-agents communicate via files only.
