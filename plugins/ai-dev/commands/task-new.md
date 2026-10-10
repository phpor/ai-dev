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
2. Match the task description against the `keywords` of each repo in the registry.
3. Present matched repos for confirmation.

### Step 2: Discover unknown repos via glab

If the task mentions a repo that is NOT already in the registry (either no match at all, or the user explicitly names a project), discover it with `glab` — do NOT scan the local filesystem.

1. Ask the user for the project name or keyword if it's ambiguous.
2. Run a GitLab search:

   ```bash
   glab search projects "<keyword>" --output json --per-page 10
   ```

3. Present the results (name, path, description, default branch) and ask the user to pick one.
4. Once confirmed, clone it to the conventional directory:

   ```bash
   REPOS_ROOT=$(jq -r '.repos_root' ~/.ai-dev/repo-registry.json | sed "s|~|$HOME|")
   mkdir -p "$REPOS_ROOT"
   glab repo clone <group/project> "$REPOS_ROOT/<project-name>"
   ```

5. Determine the default branch (try `master`, then `main`):

   ```bash
   git -C "$REPOS_ROOT/<project-name>" symbolic-ref refs/remotes/origin/HEAD | sed 's|refs/remotes/origin/||'
   ```

6. Append the new repo to `~/.ai-dev/repo-registry.json`:

   ```json
   {
     "name": "<project-name>",
     "path": "~/repos/<project-name>",
     "default_branch": "<master|main>",
     "keywords": ["<user-provided keywords>"]
   }
   ```

   Use `jq` to append safely, or write the full file back.

### Step 3: Generate task identity

- `TASK_ID` = `task-YYYYMMDD-XXXXXX` (6 random chars)
- `BRANCH_NAME` = `task/${TASK_ID}`
- `WORKTREE_ROOT` = `~/task_workspaces`

### Step 4: Set up each confirmed repo

For each repo (from registry or newly discovered):
1. `cd` to its base repo path
2. `git checkout default_branch && git pull origin default_branch`
3. `git checkout -b ${BRANCH_NAME}` (abort if already exists)
4. `git worktree add ~/task_workspaces/${TASK_ID}-${repo.name} ${BRANCH_NAME}`
5. Write `TASK.md` in the worktree with: task ID, branch, repo name, full task description, and sub-agent instructions

### Step 5: Spawn sub-agents

For each worktree, use `/subtask`:

```
/subtask --cwd <absolute-worktree-path> "Read TASK.md. Complete the task. Write SUMMARY.md when done with changes, tests, and cross-repo deps. Do not modify files outside this worktree."
```

### Step 6: Report

Print task ID, branch name, worktree paths, list of spawned sub-agents, and any newly discovered repos that were added to the registry.

### Rules

- NEVER search or scan the local filesystem for repos. Only use `glab search projects` for discovery.
- ALWAYS confirm with the user before cloning a new repo or adding it to the registry.
- NEVER modify files in base repos under `~/repos/`.
- Sub-agents communicate via files only (TASK.md in, SUMMARY.md out).
- After spawning, wait for sub-agents to report via SUMMARY.md.
- If `glab` is not installed or not authenticated (`glab auth status` fails), tell the user to install and login first.
