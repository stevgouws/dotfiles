#!/usr/bin/env bash

# Set up here instead of in projects-setup/ to avoid issues with stow ignore
# it's own root.

set -euo pipefail

SESSION="$1"
ROOT="$2"

tmux rename-window -t "=${SESSION}:1" dev
tmux new-window -t "=${SESSION}:2" -n test
tmux new-window -t "=${SESSION}:3" -n claude
tmux new-window -t "=${SESSION}:4" -n zsh
tmux select-window -t "=${SESSION}:1"
