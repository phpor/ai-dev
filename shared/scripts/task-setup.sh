#!/usr/bin/env bash
# task-setup.sh - Create worktree and branch for a new task
# Usage: task-setup.sh <repo-name> <task-id> <branch-name> [task-description]

set -euo pipefail

REPO_NAME="$1"
TASK_ID="$2"
BRANCH_NAME="$3"
TASK_DESC="${4:-}"

CONFIG_DIR="${HOME}/.ai-dev"
REGISTRY="${CONFIG_DIR}/repo-registry.json"
WORKSPACE_ROOT="${HOME}/task_workspaces"

if [ ! -f "${REGISTRY}" ]; then
  echo "ERROR: ${REGISTRY} not found. Copy shared/repo-registry.json.example first."
  exit 1
fi

REPO_PATH=$(grep -o "\"name\": \"${REPO_NAME}\"[^}]*\"path\": \"[^\"]*\"" "${REGISTRY}" | grep -o '"path": "[^"]*"' | cut -d'"' -f4 | sed "s|~|${HOME}|")
DEFAULT_BRANCH=$(grep -o "\"name\": \"${REPO_NAME}\"[^}]*\"default_branch\": \"[^\"]*\"" "${REGISTRY}" | grep -o '"default_branch": "[^"]*"' | cut -d'"' -f4)

if [ -z "${REPO_PATH}" ]; then
  echo "ERROR: Repo '${REPO_NAME}' not found in registry."
  exit 1
fi

WT_DIR="${WORKSPACE_ROOT}/${TASK_ID}-${REPO_NAME}"

echo "[task-setup] Repo: ${REPO_NAME}"
echo "[task-setup] Worktree: ${WT_DIR}"
echo "[task-setup] Branch: ${BRANCH_NAME}"

cd "${REPO_PATH}"
git checkout "${DEFAULT_BRANCH}"
git pull origin "${DEFAULT_BRANCH}"

if git show-ref --verify --quiet "refs/heads/${BRANCH_NAME}"; then
  echo "[task-setup] Branch ${BRANCH_NAME} already exists."
else
  git checkout -b "${BRANCH_NAME}"
fi

if [ -d "${WT_DIR}" ]; then
  echo "[task-setup] Worktree already exists at ${WT_DIR}"
else
  git worktree add "${WT_DIR}" "${BRANCH_NAME}"
fi

cat > "${WT_DIR}/TASK.md" <<EOF
# Task: ${TASK_ID}
Branch: ${BRANCH_NAME}
Repo: ${REPO_NAME}
Created: $(date -Iseconds)

## Task Description
${TASK_DESC:-<fill in your task here>}

## Sub-agent Instructions
1. Read this file and understand the task.
2. All code changes must stay inside this worktree.
3. Run tests before finishing.
4. When done, write SUMMARY.md with files changed, test results, cross-repo deps.
5. Do NOT modify the base repo at ${REPO_PATH}.
EOF

echo "[task-setup] Done. Worktree ready at: ${WT_DIR}"
