#!/usr/bin/env bash
# task-clean.sh - Remove worktree and optionally delete branch
# Usage: task-clean.sh <task-id> [--keep-branch]

set -euo pipefail

TASK_ID="$1"
KEEP_BRANCH="${2:-}"
BRANCH_NAME="task/${TASK_ID}"
WORKSPACE_ROOT="${HOME}/task_workspaces"
REGISTRY="${HOME}/.ai-dev/repo-registry.json"

if [ ! -f "${REGISTRY}" ]; then
  echo "ERROR: ${REGISTRY} not found."
  exit 1
fi

REPO_NAMES=$(grep -o '"name": "[^"]*"' "${REGISTRY}" | cut -d'"' -f4 | grep -v workspace_root | grep -v repos_root)

CLEANED=0
SKIPPED=0

for REPO_NAME in ${REPO_NAMES}; do
  REPO_PATH=$(grep -o "\"name\": \"${REPO_NAME}\"[^}]*\"path\": \"[^\"]*\"" "${REGISTRY}" | grep -o '"path": "[^"]*"' | cut -d'"' -f4 | sed "s|~|${HOME}|")
  WT_DIR="${WORKSPACE_ROOT}/${TASK_ID}-${REPO_NAME}"

  if [ ! -d "${WT_DIR}" ]; then
    echo "[clean] ${REPO_NAME}: no worktree, skip."
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  DIRTY=$(git -C "${WT_DIR}" status --porcelain 2>/dev/null || true)
  if [ -n "${DIRTY}" ]; then
    echo "[clean] WARNING: ${REPO_NAME} has uncommitted changes."
    read -p "Force remove? [y/N] " yn
    if [ "$yn" != "y" ] && [ "$yn" != "Y" ]; then
      echo "[clean] Skipping ${REPO_NAME}."
      continue
    fi
    FORCE_FLAG="--force"
  else
    FORCE_FLAG=""
  fi

  git -C "${REPO_PATH}" worktree remove ${FORCE_FLAG} "${WT_DIR}"
  echo "[clean] ${REPO_NAME}: worktree removed."
  CLEANED=$((CLEANED + 1))

  if [ "${KEEP_BRANCH}" != "--keep-branch" ]; then
    if git -C "${REPO_PATH}" show-ref --verify --quiet "refs/heads/${BRANCH_NAME}"; then
      git -C "${REPO_PATH}" branch -D "${BRANCH_NAME}"
      echo "[clean] ${REPO_NAME}: branch deleted."
    fi
  fi

  git -C "${REPO_PATH}" worktree prune
done

echo ""
echo "[clean] ${CLEANED} cleaned, ${SKIPPED} skipped."
