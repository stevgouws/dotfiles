#!/usr/bin/env bash
set -euo pipefail

SESSION="$1"
ROOT="$2"

tmux rename-window -t "=${SESSION}:1" dev
tmux send-keys -t "=${SESSION}:1" "cd $ROOT/wfe/app" Enter
tmux send-keys -t "=${SESSION}:1" "VSP_API_TARGET=https://bleeding-edge.dev.voxsmart.ai pnpm start"
tmux split-window -h -d -t "=${SESSION}:1" -c "$ROOT"
tmux send-keys -t "=${SESSION}:1.{right}" "nvim tfe/app/local-config/jdbc.properties" Enter
tmux split-window -v -d -t "=${SESSION}:1.{left}" -c "$ROOT/wfe/app"
tmux send-keys -t "=${SESSION}:1.{bottom-left}" "pnpm start"

tmux new-window -t "=${SESSION}:2" -n test -c "$ROOT/wfe/app"
tmux new-window -t "=${SESSION}:3" -n claude "claude"
tmux new-window -t "=${SESSION}:4" -n zsh
tmux new-window -t "=${SESSION}:5" -n e2e

tmux split-window -h -t "=${SESSION}:3" -c "$ROOT"
tmux select-pane -t "=${SESSION}:3.1"
tmux select-window -t "=${SESSION}:1.1"
