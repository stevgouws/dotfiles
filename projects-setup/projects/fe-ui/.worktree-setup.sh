#!/usr/bin/env bash
set -euo pipefail

MAIN_WORKTREE="$HOME/projects/fe-ui"

pnpm install
cp "$MAIN_WORKTREE/.env" .
cp "$MAIN_WORKTREE/appconfig.json" .
cp "$MAIN_WORKTREE/.claude/settings.local.json" ./.claude/
pnpm build