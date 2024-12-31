function source_files_in_dir() {
    SHDROPINDIRS="$1"
    while read -rd: dir; do
        if [ -d "$dir" ]; then
            for sourcefile in "${dir}"/*; do
                source "${sourcefile}" &> /dev/null
            done
        fi
    done <<< "$SHDROPINDIRS:"
}

function addToPath() {
    if [[ "$PATH" != *"$1"* ]]; then
        export PATH=$PATH:$1
    fi
}

function man() {
  LESS_TERMCAP_mb=$'\e[01;31m' \
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[45;93m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[4;93m' \
    /usr/bin/man "$@"
}

export ZSH="$HOME/.oh-my-zsh"
export editor='nvim'

ZSH_THEME="jnrowe"
DISABLE_UPDATE_PROMPT="true"

# zstyle -t ':omz:plugin:tmux:auto' start 'yes'

source $ZSH/oh-my-zsh.sh

[ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

export USE_GKE_GCLOUD_AUTH_PLUGIN=True

export GOROOT=/usr/local/go
export GOPATH=$HOME/go

export NVM_DIR="$HOME/.nvm"
function init_nvm() {
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

setopt histignorealldups
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# Paths
addToPath $HOME/.yarn/bin
addToPath $HOME/.config/yarn/global/node_modules/.bin
addToPath $HOME/.cargo/bin
addToPath $HOME/.rustup
addToPath $HOME/.krew/bin addToPath $HOME/.local/bin
addToPath $HOME/bin
addToPath $GOROOT/bin
addToPath $GOPATH/bin
addToPath $HOME/.pulumi/bin
addToPath $HOME/.config/composer/vendor/bin
addToPath $HOME/.local/bin
