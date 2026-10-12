---
name: task-new
description: Create a new task-isolated worktree, branch, and spawn a sub-agent for development
---

# /task-new

Create an isolated worktree + branch for a new task and spawn a sub-agent to do the work.

## HARD CONSTRAINTS (read first)

- **NEVER search, scan, walk, or guess local directories** (e.g. `find ~`, `ls`, Glob over `~/code`, `~/projects`, etc.) to find a repo. The local filesystem is off-limits for discovery.
- **ONLY source repos from two places**: (1) the `~/.ai-dev/repo-registry.json` you just read, or (2) `glab search projects` on GitLab. Nothing else.
- **`~/repos/` (the `repos_root` in registry) is the ONLY canonical local source directory.** Never use or reference a repo that already exists elsewhere on disk (e.g. `~/code/`, `~/work/`, `~/projects/`). If a new project is discovered, always clone it fresh into `$REPOS_ROOT/<project-name>`, even if it already exists somewhere else locally. The registry `path` field must always point under `$REPOS_ROOT`.
- If glab returns nothing useful, ask the user to provide the exact GitLab path (e.g. `group/project`). Do not improvise by looking around the disk.

## Directory layout

Each task gets its own directory. All repos for that task are checked out as subdirectories:

```
~/task_workspaces/
├── task-login-pwd-20261010-a1b2c3/
│   ├── TASK.md                          # task description
│   ├── archive.json                     # task metadata (for archive/restore)
│   ├── SUMMARY-user-service.md
│   ├── SUMMARY-auth-common.md
│   ├── user-service/                    # git worktree
│   └── auth-common/                     # git worktree
```

TASK.md, archive.json, and SUMMARY-<repo>.md live outside any worktree.

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
4. Once confirmed, clone it to the canonical directory under `$REPOS_ROOT` — **do NOT reuse an existing local clone elsewhere**, even if one exists:

   ```bash
   REPOS_ROOT=$(jq -r '.repos_root' ~/.ai-dev/repo-registry.json | sed "s|~|$HOME|")
   mkdir -p "$REPOS_ROOT"
   # If already cloned to $REPOS_ROOT, pull latest; otherwise clone fresh.
   if [ -d "$REPOS_ROOT/<project-name>/.git" ]; then
     git -C "$REPOS_ROOT/<project-name>" pull
   else
     glab repo clone <group/project> "$REPOS_ROOT/<project-name>"
   fi
   ```

   The registry entry `path` will always be `$REPOS_ROOT/<project-name>`, never some other location on disk.

5. Determine the default branch (try `master`, then `main`):

   ```bash
   git -C "$REPOS_ROOT/<project-name>" symbolic-ref refs/remotes/origin/HEAD | sed 's|refs/remotes/origin/||'
   ```

6. **Automatically update the registry** — do NOT wait for the user to explicitly ask. After cloning, present the proposed entry and confirm with the user before writing:

   ```
   I'll add this to ~/.ai-dev/repo-registry.json:
   {
     "name": "<project-name>",
     "path": "~/repos/<project-name>",
     "default_branch": "<master|main>",
     "keywords": ["<auto-inferred keywords from project description and user's task>"]
   }
   Is this correct? (y/n/edit)
   ```

   - Auto-infer keywords from the GitLab project description, topics, and the user's task context.
   - If the user says yes, write it with `jq`:
     ```bash
     jq '.repos += [{name: "<name>", path: "~/repos/<name>", default_branch: "<branch>", keywords: [...]}]' ~/.ai-dev/repo-registry.json > /tmp/registry.json && mv /tmp/registry.json ~/.ai-dev/repo-registry.json
     ```
   - If the user wants to edit keywords or name, apply their changes then write.
   - This way next time the repo matches automatically without glab search.

### Step 3: Generate task identity, name, and branch

1. **Meaningful task name**: Write a concise human-readable title for the task (e.g. "Add password strength validation to login"). This is stored in archive.json and shown in /task-list.
2. Pick a conventional commit type:
   - `feat` — new feature
   - `fix` — bug fix
   - `refactor` — code refactoring with no behavior change
   - `docs` — documentation only
   - `chore` — build, tooling, dependencies
   - `perf` — performance improvement
   - `test` — adding or fixing tests
3. Summarize the task into 3–5 words in kebab-case for the directory slug.
4. Generate a short unique suffix: `YYYYMMDD-XXXXXX` (6 random chars).
5. Ask the user to confirm or edit the task name and branch name before proceeding.

Format:

```
TASK_NAME    = "Add password strength validation to login"
TASK_DIR     = ~/task_workspaces/task-login-pwd-20261010-a1b2c3
BRANCH_NAME  = feat/login-pwd-20261010-a1b2c3
```

### Step 4: Set up each confirmed repo

1. Create the task directory: `mkdir -p ~/task_workspaces/task-<summary>-<date>-<random6>`
2. Write `TASK.md` in the task directory with: task name, branch name, repos involved, full task description, and sub-agent instructions.
3. Write `archive.json` in the task directory:

   ```json
   {
     "task_name": "<meaningful name>",
     "task_id": "task-<summary>-<date>-<random6>",
     "branch": "<type>/<summary>-<date>-<random6>",
     "created_at": "<ISO timestamp>",
     "description": "<original task description>",
     "repos": {
       "<repo-name>": {
         "base_path": "~/repos/<repo-name>",
         "default_branch": "<master|main>",
         "last_commit": null,
         "pushed_to_remote": false,
         "remote_branch": null
       }
     }
   }
   ```

4. For each repo:
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
/subtask --cwd <absolute-worktree-path> "Read ../TASK.md in the parent task directory. Complete the task. Do NOT modify files inside this worktree beyond your code changes, and do not touch other worktrees.

REQUIRED WORKFLOW:
1. Make the code changes.
2. Run the project's test suite. Fix any failures.
3. Self-review your own diff: run `git diff` and read every change critically — check for bugs, edge cases, missing error handling, style inconsistencies, leftover debug code, and anything you would flag in a PR review.
4. Fix every issue you find. Re-run tests.
5. Repeat steps 3–4 until a self-review pass finds zero new issues.
6. Only then write ../SUMMARY-<repo-name>.md in the parent task directory (NOT inside this worktree) with: files changed, test results, cross-repo deps, and a note confirming the self-review loop ran clean."
```

### Step 7: Report

Print task name, task directory path, branch name, list of worktrees, list of spawned sub-agents, and any newly discovered repos added to the registry.

### Rules

- **NEVER search, scan, or guess repos on the local filesystem.** No `find`, no `ls` over `~/code`, no Glob, no reading `.git/config` of random directories. Discovery is registry-first, glab-second, ask-user-third.
- **`~/repos/` (repos_root) is the only canonical local source.** Never reuse clones from other directories. Always clone to `$REPOS_ROOT/<project-name>`.
- **When a new repo is discovered via glab, automatically propose adding it to the registry** — don't wait for the user to ask. Confirm the entry before writing.
- **ALWAYS confirm the task name and branch name with the user before creating it.**
- **ALWAYS confirm task understanding with the user AFTER exploring code but BEFORE spawning sub-agents.** Do not skip this step.
- **NEVER modify files in base repos under `~/repos/`.**
- Sub-agents communicate via files only (TASK.md in, SUMMARY-<repo>.md out).
- After spawning, wait for sub-agents to report via SUMMARY files.
- **Every sub-agent MUST self-review its own diff iteratively** (`git diff` → fix issues → re-test → repeat) until a clean pass, before writing SUMMARY.md.
- If `glab` is not installed or not authenticated (`glab auth status` fails), tell the user to install and login first.
