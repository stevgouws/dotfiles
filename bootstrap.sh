#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config)
      PROFILE="${2:?Missing value for --config}"
      shift 2
      ;;
    *)
      echo "Usage: $0 --config work|personal"
      exit 1
      ;;
  esac
done

if [[ -z "$PROFILE" ]]; then
  echo "Usage: $0 --config work|personal"
  exit 1
fi

install_homebrew() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

# So it can use brew before it's in the PATH
setup_brew_shellenv() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

run_brewfile() {
  local name="$1"
  local file="$DOTFILES_DIR/Brewfile.$name"

  if [[ ! -f "$file" ]]; then
    echo "Missing Brewfile: $file"
    exit 1
  fi

  echo "Installing $name packages..."
  brew bundle --file="$file"
}

install_homebrew
setup_brew_shellenv

run_brewfile base

case "$PROFILE" in
  work) run_brewfile work ;;
  personal) run_brewfile personal ;;
  *)
    echo "Usage: $0 --config work|personal"
    exit 1
    ;;
esac

echo "Linking dot files..."
stow -d "$DOTFILES_DIR" . -t ~/.config

echo "Bootstrap complete."