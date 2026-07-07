#!/usr/bin/env bash
set -euo pipefail

MAIN_WORKTREE="$HOME/projects/fe-ui"

pnpm install
# pnpm local:init-app-config-and-dotenv-files
cp "$MAIN_WORKTREE/.env" .
cp "$MAIN_WORKTREE/.env.iis" .
cp "$MAIN_WORKTREE/appconfig.json" .
cp "$MAIN_WORKTREE/packages/e2e/.env.e2e" packages/e2e/
cp "$MAIN_WORKTREE/packages/test-utils/.env.test" packages/test-utils/
pnpm -r --filter '!@vcs-ui2/app' --filter '!@vcs-ui2/user-guides' run build