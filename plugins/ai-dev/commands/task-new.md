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

## Directory layout

Each task gets its own directory. All repos for that task are checked out as subdirectories:

```
~/task_workspaces/
├── task-login-pwd-20261010-a1b2c3/     # one task directory
│   ├── TASK.md                          # task description, shared by all sub-agents
│   ├── user-service/                    # git worktree for this repo
│   └── auth-common/                     # git worktree for this repo
└── fix-timeout-20261010-b2c3d4/
    ├── TASK.md
    └── api-gateway/
```

All repos for one task share the same branch name.

## Instructions

You are the main orchestrator. Set up an isolated task environment and delegate to sub-agents.

### Step 1: Parse task and identify repos

1. Read `~/.ai-dev/repo-registry.json`. If missing, tell user to copy from `${CLAUDE_PLUGIN_ROOT}/shared/repo-registry.json.example` first.
2. Match the task description against the `keywords` of each repo in the registry.
3. **Clarify with the user**:
   - If you are NOT confident which repos are involved (keyword matches are weak, multiple repos could apply, or the task is ambiguous), ask the user to confirm: "I think this task involves X and Y repos. Is that correct?"
   - If no repos match at all, explicitly ask the user which repos to use.
   - Do NOT proceed until the user confirms the repo list.

### Step 2: Discover unknown repos via glab

If the user names a repo that is NOT already in the registry, discover it with `glab` — do NOT scan the local filesystem.

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
TASK_DIR     = ~/task_workspaces/task-<summary>-<date>-<random6>
BRANCH_NAME  = <type>/<summary>-<date>-<random6>
```

Examples:
- `~/task_workspaces/task-login-pwd-20261010-a1b2c3/`
- branch: `feat/login-pwd-20261010-a1b2c3`

### Step 4: Set up each confirmed repo

1. Create the task directory: `mkdir -p ~/task_workspaces/task-<summary>-<date>-<random6>`
2. Write `TASK.md` in the task directory with: branch name, repos involved, full task description, and sub-agent instructions.
3. For each repo:
   - `cd` to its base repo path
   - `git checkout default_branch && git pull origin default_branch`
   - `git checkout -b ${BRANCH_NAME}` (if already exists, append another short suffix or ask user)
   - `git worktree add ~/task_workspaces/task-<...>/<repo.name> ${BRANCH_NAME}`

### Step 5: Analyze code and confirm task understanding

**Before spawning any sub-agents, explore the codebases and confirm your understanding with the user.**

1. For each worktree, quickly explore the codebase:
   - Read top-level files (README, package.json, go.mod, etc.) to understand the project
   - Find the relevant modules/files mentioned in the task
   - Note architecture, conventions, and any cross-repo dependencies
2. Formulate your understanding of the task:
   - What exactly needs to change in each repo
   - Which files/modules are involved
   - How the repos depend on each other
   - Potential risks or questions
3. Present this understanding to the user in a clear summary and **ask**: "Does this match what you want? Any corrections before I start sub-agents?"
4. Only proceed to Step 6 after the user confirms. If the user corrects you, update TASK.md accordingly.

### Step 6: Spawn sub-agents

For each repo worktree, use `/subtask`:

```
/subtask --cwd <absolute-worktree-path> "Read ../TASK.md in the parent directory. Complete the task. Write SUMMARY.md in this worktree when done with changes, tests, and cross-repo deps. Do not modify files outside this worktree."
```

### Step 7: Report

Print task directory path, branch name, list of worktrees, list of spawned sub-agents, and any newly discovered repos added to the registry.

### Rules

- **NEVER search, scan, or guess repos on the local filesystem.** No `find`, no `ls` over `~/code`, no Glob, no reading `.git/config` of random directories. Discovery is registry-first, glab-second, ask-user-third.
- **ALWAYS confirm with the user before cloning a new repo or adding it to the registry.**
- **ALWAYS confirm the generated branch name with the user before creating it.**
- **ALWAYS confirm task understanding with the user AFTER exploring code but BEFORE spawning sub-agents.** Do not skip this step.
- **NEVER modify files in base repos under `~/repos/`.**
- Sub-agents communicate via files only (TASK.md in, SUMMARY.md out).
- After spawning, wait for sub-agents to report via SUMMARY.md.
- If `glab` is not installed or not authenticated (`glab auth status` fails), tell the user to install and login first.
