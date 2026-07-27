#!/usr/bin/env bash
set -euo pipefail

SESSION="$1"
ROOT="$2"

tmux rename-window -t "=${SESSION}:1" dev
tmux new-window -t "=${SESSION}:2" -n test "npx vitest"
tmux new-window -t "=${SESSION}:3" -n claude
tmux new-window -t "=${SESSION}:4" -n zsh
tmux new-window -t "=${SESSION}:5" -n node "node"
tmux new-window -t "=${SESSION}:6" -n glob -c "$ROOT/glob"
tmux select-window -t "=${SESSION}:1" 
