# Homebrew
export HOMEBREW_NO_AUTO_UPDATE=1
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
fi

# Pipenv
export PIPENV_VENV_IN_PROJECT=1

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
if [ -d "$PYENV_ROOT/bin" ]; then
    export PATH="$PYENV_ROOT/bin:$PATH"
fi
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

# Poetry
export PATH="$HOME/.local/bin:$PATH"

# Starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
    if [[ -n "$STARSHIP_THEME" ]]; then
        starship config palette "$STARSHIP_THEME"
    fi
fi

# Git completion
if [ -f "$HOME/.config/zsh/git-completion.bash" ]; then
    zstyle ':completion:*:*:git:*' script "$HOME/.config/zsh/git-completion.bash"
fi
fpath=("$HOME/.config/zsh" $fpath)
autoload -Uz compinit && compinit

# Redshift
export ODBCINI="$HOME/.odbc.ini"
export ODBCSYSINI="/opt/amazon/redshift/Setup"
export AMAZONREDSHIFTODBCINI="/opt/amazon/redshift/lib/amazon.redshiftodbc.ini"
export DYLD_LIBRARY_PATH="${DYLD_LIBRARY_PATH:-}:/usr/local/lib"

# fzf
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"
if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --zsh)" 2>/dev/null || true
fi

export FZF_CTRL_T_OPTS="
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"
export FZF_DEFAULT_COMMAND='rg --hidden -l ""'

bindkey "ç" fzf-cd-widget 2>/dev/null || true

fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

fh() {
  eval "$( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')"
}

# zoxide
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init --cmd cd zsh)"
fi

if command -v brew >/dev/null 2>&1; then
    zsh_syntax="$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    zsh_autosuggest="$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

    [ -f "$zsh_syntax" ] && source "$zsh_syntax"
    (( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
    ZSH_HIGHLIGHT_STYLES[path]=none
    ZSH_HIGHLIGHT_STYLES[path_prefix]=none

    [ -f "$zsh_autosuggest" ] && source "$zsh_autosuggest"
fi

# Vi mode
bindkey -v
export KEYTIMEOUT=1
export VI_MODE_SET_CURSOR=true

function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]]; then
    echo -ne '\e[2 q'
  else
    echo -ne '\e[6 q'
  fi
}
zle -N zle-keymap-select

zle-line-init() {
  zle -K viins
  echo -ne '\e[6 q'
}
zle -N zle-line-init
echo -ne '\e[6 q'

function vi-yank-xclip {
  zle vi-yank
  echo "$CUTBUFFER" | pbcopy -i
}

zle -N vi-yank-xclip
bindkey -M vicmd 'y' vi-yank-xclip

autoload edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line
