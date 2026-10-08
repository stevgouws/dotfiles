#!/usr/bin/env bash
# Copies personal, git-ignored config from the main checkout into a new worktree, then installs
# dependencies. Tracked files are never copied: the worktree's branch already has the right version.
set -euo pipefail

MAIN_WORKTREE="$HOME/projects/github-vsp"
WORKTREE_DIR="$(cd "$(dirname "$0")" && pwd)"

files=(
  .env.local
  tfe/app/local-config/jdbc.properties
)

for f in "${files[@]}"; do
  src="$MAIN_WORKTREE/$f"
  dest="$WORKTREE_DIR/$f"
  if git -C "$WORKTREE_DIR" ls-files --error-unmatch "$f" > /dev/null 2>&1; then
    echo "skip $f: tracked on this branch"
  elif [ ! -f "$src" ]; then
    echo "skip $f: not in $MAIN_WORKTREE"
  elif [ -e "$dest" ]; then
    echo "skip $f: already present"
  else
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    echo "copied $f"
  fi
done

cd "$WORKTREE_DIR"
mvn clean install -DskipTests
(cd wfe/app && pnpm install)
