# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
# You can keep robbyrussell or change to another theme
# Since you use Starship, you might want to set this to empty or a minimal theme
ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
# Add more plugins here for better functionality
plugins=(
  git
  sudo
  copypath
  copyfile
  extract
  web-search
  jsontools
  docker
  docker-compose
  npm
  node
  python
  pip
  fzf
  colored-man-pages
  command-not-found
  
  # Custom plugins (install these first)
  zsh-autosuggestions
  fast-syntax-highlighting
  zsh-completions
  fzf-tab
  you-should-use
  zsh-history-substring-search
)

source $ZSH/oh-my-zsh.sh

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

zstyle ':bracketed-paste-magic' active-widgets '.self-*'


# ============================================
# YOUR CUSTOM CONFIGURATION BELOW
# ============================================

# History settings
HISTSIZE=1000
SAVEHIST=2000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt APPEND_HISTORY
setopt SHARE_HISTORY

# Color support for ls
if [[ -x /usr/bin/dircolors ]]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# Aliases
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias tree='eza --tree --icons'

alias nv="nvim"
alias sane="stty sane"
alias lg="lazygit"

alias cd="z"
alias j="z"
alias jj="zi"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias c="clear"
alias home="cd ~"

alias please='sudo $(fc -ln -1)'

alias vrc="nvim ~/.config/nvim/"
alias zrc="nvim ~/.zshrc"
alias r='source ~/.zshrc && echo "✅ zshrc reloaded"'

alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias gco="git checkout"
alias gb="git branch"
alias gl="git log --oneline --graph --decorate"
alias gd="git diff"
alias clone="git clone"

alias img='kitten icat'

alias mycloc='cloc --exclude-dir=node_modules,dist,build,.git,.vscode,.idea,coverage,.next,out,.vercel,.turbo,.cache --exclude-ext=json,log,txt,yml,yaml,lock,svg,png,jpg,jpeg,gif,ico,env . | ccze -A'
alias loc='tokei .'

alias clip='wl-copy' 
alias clipp='wl-paste' 

# Copy current directory path
alias cwd='pwd | wl-copy && echo "$(pwd)"'
alias poke='pokemon-colorscripts'

# Better cat
alias cat='bat --theme="Visual Studio Dark+"'

alias ff='fastfetch'

alias http='curlie'

alias open='xdg-open'

#alias curl='curl --proto-default https'

# Colorized output
export LESS='-R'
export LESSOPEN='|~/.lessfilter %s'

# FZF customization
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --color=always {}'"

# Custom functions
mkcd() {
  mkdir -p "$1" && cd "$1"
}

typeset -A pomo_options
pomo_options=(
  work 45
  break 15
  emacs 30
)

pomodoro() {
  if [[ -n $1 && -n ${pomo_options[$1]} ]]; then
    local val=$1
    timer "${pomo_options[$val]}m"
    notify-send "$val session done"
  fi
}
unalias wo br 2>/dev/null

wo() { pomodoro work }
br() { pomodoro break }

# pnpm fzf function
_pnpm_fzf_run() {
  if [[ ! -f package.json ]]; then
    echo "No package.json found"
    return 1
  fi

  local script
  script=$(jq -r '.scripts | keys[]' package.json | fzf --prompt="Select pnpm script: ")

  if [[ -n "$script" ]]; then
    echo "pnpm run $script"
    pnpm run "$script"
  fi
}

alias pnp="_pnpm_fzf_run"

# Source additional files
if [[ -f ~/.zsh_aliases ]]; then
  source ~/.zsh_aliases
fi

# Environment variables and tools
if [[ -f "$HOME/.cargo/env" ]]; then
  source "$HOME/.cargo/env"
fi

eval "$(zoxide init zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/zsh_completion" ] && \. "$NVM_DIR/zsh_completion"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export DATABASE_PASSWORD="1234"

# pnpm
export PNPM_HOME="/home/eren/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

export FLYCTL_INSTALL="/home/eren/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"

# Initialize Starship (comment this out if you want to use Oh My Zsh themes instead)
eval "$(starship init zsh)"


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/eren/miniconda3/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
if [ $? -eq 0 ]; then
  eval "$__conda_setup"
else
  if [ -f "/home/eren/miniconda3/etc/profile.d/conda.sh" ]; then
    . "/home/eren/miniconda3/etc/profile.d/conda.sh"
  else
    export PATH="/home/eren/miniconda3/bin:$PATH"
  fi
fi
unset __conda_setup
# <<< conda initialize <<<

export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
export PATH=$PATH:/usr/local/go/bin
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/scripts:$PATH"

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"

export PATH="$HOME/.platformio/penv/bin:$PATH"

eval "$(direnv hook zsh)"

# opencode
export PATH=/home/ali/.opencode/bin:$PATH
export PATH=/home/ali/.cargo/bin/:$PATH
