#!/usr/bin/env bash
set -euo pipefail

SESSION="$1"
ROOT="$2"

tmux rename-window -t "=${SESSION}:1" dev
tmux send-keys -t "=${SESSION}:1" "cd $ROOT/wfe/app" Enter

tmux new-window -t "=${SESSION}:2" -n test -c "$ROOT/packages/app"
tmux new-window -t "=${SESSION}:3" -n claude
tmux new-window -t "=${SESSION}:4" -n zsh
tmux new-window -t "=${SESSION}:5" -n e2e

tmux select-window -t "=${SESSION}:1"