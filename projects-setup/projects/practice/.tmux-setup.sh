#!/usr/bin/env bash
set -euo pipefail

SESSION="$1"
ROOT="$2"

if is-work-macbook; then
  AGENT_WINDOW_NAME="claude"
else
  AGENT_WINDOW_NAME="codex"
fi

tmux rename-window -t "=${SESSION}:1" zsh
tmux new-window -t "=${SESSION}:2" -n test "npx vitest"
tmux new-window -t "=${SESSION}:3" -n "$AGENT_WINDOW_NAME"
tmux new-window -t "=${SESSION}:4" -n zsh
tmux new-window -t "=${SESSION}:5" -n node "node"
tmux new-window -t "=${SESSION}:6" -n glob -c "$ROOT/glob"
tmux select-window -t "=${SESSION}:1"
