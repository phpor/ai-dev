# new-task (Codex)

## Task: Create a new task-first development environment

### Input
User provides a natural language task description.

### Instructions for the main agent

1. Read the repo registry at ~/.ai-dev/repo-registry.json. If missing, ask user to set it up first.
2. Match repos from the task description using keywords. Present matches for user confirmation.
3. Generate task ID: task-YYYYMMDD-XXXXXX (6 random chars). Branch: task/${TASK_ID}.
4. For each matched repo:
   - cd to base repo
   - git checkout default_branch && git pull origin default_branch
   - git checkout -b ${BRANCH_NAME}
   - git worktree add ~/task_workspaces/${TASK_ID}-${repo.name} ${BRANCH_NAME}
   - Write TASK.md in the worktree with task details and sub-agent instructions.
5. Spawn sub-agents using spawn_agent tool:
   - For each worktree, call spawn_agent with:
     - cwd: absolute path to the worktree
     - prompt: "Read TASK.md. Complete the task. Write SUMMARY.md when done with changes, tests, cross-repo deps."
6. Report task ID, branch name, and worktree paths.

### Rules
- Never modify base repos in ~/repos/.
- Abort if branch already exists.
- Sub-agents communicate via files (TASK.md in, SUMMARY.md out).
- Max 6 concurrent sub-agents.
