#!/usr/bin/env bash
set -euo pipefail

MAIN_WORKTREE="$HOME/projects/fe-ui"

pnpm install
cp "$MAIN_WORKTREE/.env" .