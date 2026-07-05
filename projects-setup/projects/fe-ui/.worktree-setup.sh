#!/usr/bin/env bash
set -euo pipefail

MAIN_WORKTREE="$HOME/projects/fe-ui"

pnpm install
pnpm local:init-app-config-and-dotenv-files
pnpm -r --filter '!@vcs-ui2/app' --filter '!@vcs-ui2/user-guides' run build
cp "$MAIN_WORKTREE/packages/e2e/.env.e2e" packages/e2e/
cp "$MAIN_WORKTREE/.env" .
cp "$MAIN_WORKTREE/.env.iis" .
