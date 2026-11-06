export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="refined"

plugins=(
  git
  zsh-autosuggestions
  history-substring-search
)

source $ZSH/oh-my-zsh.sh

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# PATH (guarded so missing tools don't break other machines)
path_prepend() { [[ -d $1 ]] && export PATH="$1:$PATH"; }
path_append()  { [[ -d $1 ]] && export PATH="$PATH:$1"; }

path_append  "$HOME/.pub-cache/bin"
export GEM_HOME=$HOME/.gem
path_prepend /opt/homebrew/opt/ruby/bin
path_prepend "$GEM_HOME/bin"
path_prepend /opt/homebrew/opt/openjdk@21/bin
path_prepend "$HOME/.local/bin"

if [[ -x /usr/libexec/java_home ]]; then
  export JAVA_HOME=$(/usr/libexec/java_home -v 21 2>/dev/null)
fi

# Dart CLI completion
[[ -f $HOME/.dart-cli-completion/zsh-config.zsh ]] && . $HOME/.dart-cli-completion/zsh-config.zsh

# Aliases
alias lg='lazygit'
alias nv='nvim .'
alias v='nv'
alias ll='ls -ll'
alias yy='pwd | pbcopy'
alias wm='workmux'
alias wd='workmux dashboard'
alias j='just'

fpath+=~/.zfunc; autoload -Uz compinit; compinit

# Tab accepts the autosuggestion if one is shown, otherwise completes normally
tab-accept-or-complete() {
  if [[ -n $POSTDISPLAY ]]; then
    zle autosuggest-accept
  else
    zle expand-or-complete
  fi
}
ZSH_AUTOSUGGEST_IGNORE_WIDGETS+=(tab-accept-or-complete)  # else the plugin clears POSTDISPLAY before we read it
zle -N tab-accept-or-complete
bindkey '^I' tab-accept-or-complete

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

if command -v zoxide >/dev/null; then
  eval "$(zoxide init --cmd cd zsh)"
fi

spf() {
    os=$(uname -s)

    if [[ "$os" == "Linux" ]]; then
        export SPF_LAST_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/superfile/lastdir"
    fi

    if [[ "$os" == "Darwin" ]]; then
        export SPF_LAST_DIR="$HOME/Library/Application Support/superfile/lastdir"
    fi

    command spf "$@"

    [ ! -f "$SPF_LAST_DIR" ] || {
        . "$SPF_LAST_DIR"
        rm -f -- "$SPF_LAST_DIR" > /dev/null
    }
}

# Machine-specific and secret config (not tracked in git)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
