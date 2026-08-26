#!/usr/bin/env bash
# Push to GitHub bypassing global ghfast.top URL rewrite (which breaks gh token auth).
# cd /dev/gpc_code/docs/agent_search
# git add -A && git commit -m "你的说明"

# GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
#   git -c 'credential.helper=!/usr/bin/gh auth git-credential' \
#   push https://github.com/JWgpc/agent-search-plan.git main

set -euo pipefail
cd "$(dirname "$0")/.."

REMOTE="${1:-https://github.com/JWgpc/agent-search-plan.git}"
BRANCH="${2:-main}"

GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -c 'credential.helper=!/usr/bin/gh auth git-credential' \
  push -u "$REMOTE" "$BRANCH"

echo "Pushed to $REMOTE ($BRANCH)"
