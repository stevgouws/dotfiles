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

clone_repos() {
  local name="$1"
  local file="$DOTFILES_DIR/repos.$name"

  if [[ ! -f "$file" ]]; then
    echo "Missing repos file: $file"
    exit 1
  fi

  while read -r url folder; do
    [[ -z "$url" || "$url" == \#* ]] && continue
    if [[ -z "$folder" ]]; then
      folder=$(basename "$url" .git)
    fi
    if [[ -d ~/projects/"$folder" ]]; then
      echo "  Skipping $folder (already exists)"
    else
      echo "  Cloning $folder"
      git clone "$url" ~/projects/"$folder"
    fi
  done < "$file"
}

install_homebrew
setup_brew_shellenv

run_brewfile base
run_brewfile "$PROFILE"

echo "Linking dot files..."
stow -d "$DOTFILES_DIR" . -t ~/.config

echo "Changing Hammerspoon config path to ~/.config/hammerspoon/init.lua..."
defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"

echo "Creating Obsidian vault folders..."

echo "  Creating ~/obsidian-sync/VoxSmart"
mkdir -p ~/obsidian-sync/VoxSmart

if [[ "$PROFILE" == "personal" ]]; then
  echo "  Creating ~/obsidian-sync/Vault13"
  mkdir -p ~/obsidian-sync/Vault13
  echo "  Creating ~/obsidian-sync/Vault3"
  mkdir -p ~/obsidian-sync/Vault3
fi

echo "Cloning repos..."
mkdir -p ~/projects
clone_repos base
clone_repos "$PROFILE"

echo "Bootstrap complete."