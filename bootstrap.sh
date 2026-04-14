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

# install_homebrew
setup_brew_shellenv

# run_brewfile base
run_brewfile "$PROFILE"

echo "Linking dot files..."
stow -d "$DOTFILES_DIR" */

echo "Changing Hammerspoon config path to ~/.config/hammerspoon/init.lua..."
defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"

echo "Setting MacOSdefaults"
defaults write com.apple.dock tilesize -int 24
defaults write com.apple.dock orientation -string right
defaults write com.apple.dock autohide -bool true
killall Dock
defaults write com.apple.finder AppleShowAllFiles -bool true
# This sets the default for folders that do not already have their own saved Finder view settings.
# Existing .DS_Store data can override it for specific folders.
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
killall Finder
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15
defaults write -g com.apple.mouse.scaling -float 0.875
killall SystemUIServer
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true'

# Press and hold for VScode
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

# Maccy
# Shortcut Hyper + h
defaults write org.p0deje.Maccy KeyboardShortcuts_popup -string '{"carbonKeyCode":4,"carbonModifiers":6912}'
defaults write org.p0deje.Maccy popupPosition -string center
defaults write org.p0deje.Maccy ignoredApps -array "com.bitwarden.desktop"
defaults write org.p0deje.Maccy pasteByDefault -bool true
defaults write org.p0deje.Maccy popupScreen -int 0
defaults write org.p0deje.Maccy previewDelay -int 99999
defaults write org.p0deje.Maccy showFooter -bool false
defaults write org.p0deje.Maccy searchVisibility -string duringSearch
defaults write org.p0deje.Maccy searchMode -string fuzzy
defaults write org.p0deje.Maccy showTitle -bool false

# Doesn't seem like I need these
# killall cfprefsd
# killall Maccy 2>/dev/null
# open -a Maccy

echo "Creating Obsidian folder..."
mkdir -p ~/obsidian-sync

echo "Cloning repos..."
mkdir -p ~/projects
clone_repos base
clone_repos "$PROFILE"

echo "Bootstrap complete."