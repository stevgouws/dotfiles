#!/usr/bin/env bash
set -euo pipefail

SESSION="$1"
ROOT="$2"

tmux new-window -t "=${SESSION}:2" -n test
tmux new-window -t "=${SESSION}:3" -n claude "claude"
tmux new-window -t "=${SESSION}:4" -n zsh
tmux select-window -t "=${SESSION}:1"
