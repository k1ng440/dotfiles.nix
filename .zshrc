export ZSH="$HOME/.oh-my-zsh"
export editor='nvim'

ZSH_THEME="jnrowe"
DISABLE_UPDATE_PROMPT="true"

# zstyle -t ':omz:plugin:tmux:auto' start 'yes'

plugins=(
    git docker golang zsh-autosuggestions aliases command-not-found
    common-aliases httpie ssh-agent terraform transfer wd
    gpg-agent rsync tmux zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh
source $HOME/.local/bin/zsh-interactive-cd.plugin.zsh

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
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

setopt histignorealldups
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

source ${HOME}/.zsh_function
source ${HOME}/.aliases
source ${HOME}/.zsh_profile

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

[ -f "$HOME/.cargo/bin/zoxide" ] && eval "$(zoxide init zsh)"
type -p gh >/dev/null && eval "$(gh completion --shell zsh)"

export CLANGD_FLAGS="--background-index --enable-config --clang-tidy"

#  direnv
eval "$(direnv hook zsh)"

if [ -d "$HOME/jdk/jdk-21.0.1" ]; then
    export JAVA_HOME="$HOME/jdk/jdk-21.0.1"
    export PATH=$JAVA_HOME/bin:$PATH
fi

# # Automatically switch node version based on .nvmrc
# autoload -U add-zsh-hook
# load-nvmrc() {
#   local node_version="$(nvm version)"
#   local nvmrc_path="$(nvm_find_nvmrc)"
#
#   if [ -n "$nvmrc_path" ]; then
#     local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")
#
#     if [ "$nvmrc_node_version" = "N/A" ]; then
#       nvm install
#     elif [ "$nvmrc_node_version" != "$node_version" ]; then
#       nvm use
#     fi
#   elif [ "$node_version" != "$(nvm version default)" ]; then
#     echo "Reverting to nvm default version"
#     nvm use default
#   fi
# }
# add-zsh-hook chpwd load-nvmrc
# load-nvmrc

# pnpm
export PNPM_HOME="/home/k1ng/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
