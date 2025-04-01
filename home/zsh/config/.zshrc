# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

bindkey -e
bindkey -s '^o' 'nvim $(fzf)^M'

bindkey '^[[1;5C' emacs-forward-word
bindkey '^[[1;5D' emacs-backward-word

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

# Load completions
autoload -Uz compinit
[[ -z "$ZSH_COMPLETION_INITIALIZED" ]] && {
    ZSH_COMPLETION_INITIALIZED=1
    compinit
}

# ZINIT plugin manager
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::aws
zinit snippet OMZP::golang
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found
zinit snippet OMZP::ssh-agent


# Add in zsh plugins
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

zinit cdreplay -q

# Aliases
alias ls='ls --color'
alias vim='nvim'
alias c='clear'
alias v='nvim'
alias nv='nvim .'
alias ll='eza -la'
alias ls='eza -a'
alias tree='eza --tree'
alias ssh='TERM=xterm-256color ssh'
alias ansible-playbook='TERM=xterm-256color ansible-playbook'

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

export editor='nvim'
[ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='nvim'
fi

export GOROOT=/usr/local/go
export GOPATH=$HOME/go

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

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

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' rehash true
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:*' continuous-trigger 'ctrl-e'
enable-fzf-tab

export NIXPKGS_ALLOW_UNFREE=1
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8


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
