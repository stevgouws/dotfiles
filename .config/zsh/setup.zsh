# https://www.youtube.com/watch?v=9U8LCjuQzdct
# https://www.youtube.com/watch?v=9U8LCjuQzdc
# https://ohmyposh.dev/docs/installation/fonts

# zsh colors module
autoload -U colors && colors

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"

source "${ZINIT_HOME}/zinit.zsh"

if [[ -f "/opt/homebrew/bin/brew" ]]; then
 # If you're using macOS, you'll want this enabled to make brew installed packages availle in your path
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Manual steps
# brew install jandedobbeleer/oh-my-posh/oh-my-posh
# also need to manually install font: https://ohmyposh.dev/docs/installation/fonts#nerd-fonts 
# oh-my-posh font install meslo
# brew install fzf
#
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"

# Vim mode
# typeset -g ZVM_ESCAPE_KEYTIMEOUT=0
#bindkey -v
# zinit ice depth=1
#zinit light jeffreytse/zsh-vi-mode

## Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
#zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Disable in ~/projects/special-repo
if [[ $PWD != $HOME/projects/practice ]]; then
  zinit light zsh-users/zsh-autosuggestions
fi

# Add in snippets
# Find more: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -U compinit && compinit

zinit cdreplay -q

# Keybindings
# Allow forward/backward search to filter by partial history completion
bindkey '^n' history-search-forward
bindkey '^p' history-search-backward
# zsh-autosuggest
## ctrl+shift+option+k
bindkey $'\e[1;8K' autosuggest-execute
## ctrl+shift+option+l
bindkey $'\e[1;8L' autosuggest-accept

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase # erase duplicates
setopt appendhistory
setopt sharehistory # share across instances
setopt hist_ignore_space # in case you don't want sensitive info to be saved, prefix with space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
# zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # make matches case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias vim='nvim'
alias c='clear'
alias l='ls -la'

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# print grey & reset colour
echo "${fg[grey]}Loaded setup.zsh…${reset_color}"

