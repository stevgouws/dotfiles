#!/usr/bin/env bash
set -euo pipefail

MAIN_WORKTREE="$HOME/projects/be-comms-svc"

pnpm install
cp "$MAIN_WORKTREE/.env" .