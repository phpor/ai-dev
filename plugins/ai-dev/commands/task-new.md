---
name: task-new
description: Create a new task-isolated worktree, branch, and spawn a sub-agent for development
---

# /task-new

Create an isolated worktree + branch for a new task and spawn a sub-agent to do the work.

## HARD CONSTRAINTS (read first)

- **NEVER search, scan, walk, or guess local directories** (e.g. `find ~`, `ls`, Glob over `~/code`, `~/projects`, etc.) to find a repo. The local filesystem is off-limits for discovery.
- **ONLY source repos from two places**: (1) the `~/.ai-dev/repo-registry.json` you just read, or (2) `glab search projects` on GitLab. Nothing else.
- If glab returns nothing useful, ask the user to provide the exact GitLab path (e.g. `group/project`). Do not improvise by looking around the disk.

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

### Step 3: Generate task identity and semantic branch name

1. Analyze the task description and pick a conventional commit type:
   - `feat` — new feature
   - `fix` — bug fix
   - `refactor` — code refactoring with no behavior change
   - `docs` — documentation only
   - `chore` — build, tooling, dependencies
   - `perf` — performance improvement
   - `test` — adding or fixing tests
2. Summarize the task into 3–5 words in kebab-case (lowercase, hyphen-separated).
3. Generate a short unique suffix: `YYYYMMDD-XXXXXX` (6 random chars).
4. Ask the user to confirm or edit the branch name before proceeding.

Format:

```
BRANCH_NAME = <type>/<short-summary>-YYYYMMDD-XXXXXX
TASK_ID     = <short-summary>-YYYYMMDD-XXXXXX
WORKTREE_ROOT = ~/task_workspaces
```

Examples:
- `feat/login-pwd-strength-20261010-a1b2c3`
- `fix/user-service-timeout-20261010-b2c3d4`
- `refactor/auth-common-jwt-20261010-e3f4a5`

Worktree directory uses the TASK_ID prefix: `~/task_workspaces/${TASK_ID}-${repo.name}`.

### Step 4: Set up each confirmed repo

For each repo (from registry or newly discovered):
1. `cd` to its base repo path
2. `git checkout default_branch && git pull origin default_branch`
3. `git checkout -b ${BRANCH_NAME}` (if already exists, append another short suffix or ask user)
4. `git worktree add ~/task_workspaces/${TASK_ID}-${repo.name} ${BRANCH_NAME}`
5. Write `TASK.md` in the worktree with: task ID, branch name, repo name, full task description, and sub-agent instructions

### Step 5: Spawn sub-agents

For each worktree, use `/subtask`:

```
/subtask --cwd <absolute-worktree-path> "Read TASK.md. Complete the task. Write SUMMARY.md when done with changes, tests, and cross-repo deps. Do not modify files outside this worktree."
```

### Step 6: Report

Print task ID, branch name, worktree paths, list of spawned sub-agents, and any newly discovered repos that were added to the registry.

### Rules

- **NEVER search, scan, or guess repos on the local filesystem.** No `find`, no `ls` over `~/code`, no Glob, no reading `.git/config` of random directories. Discovery is registry-first, glab-second, ask-user-third.
- **ALWAYS confirm with the user before cloning a new repo or adding it to the registry.**
- **ALWAYS confirm the generated branch name with the user before creating it.**
- **NEVER modify files in base repos under `~/repos/`.**
- Sub-agents communicate via files only (TASK.md in, SUMMARY.md out).
- After spawning, wait for sub-agents to report via SUMMARY.md.
- If `glab` is not installed or not authenticated (`glab auth status` fails), tell the user to install and login first.
