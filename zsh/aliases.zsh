# System
alias shutdown='sudo shutdown now'
alias restart='sudo reboot'
alias sleep='pmset sleepnow'
alias cls='clear'
alias c='codex'
alias e='exit'
alias vim='nvim'

# Git
alias g='git'
alias ga='git add'
alias gafzf='git ls-files -m -o --exclude-standard | grep -v "__pycache__" | fzf -m --print0 | xargs -0 -o -t git add'
alias grmfzf='git ls-files -m -o --exclude-standard | fzf -m --print0 | xargs -0 -o -t git rm'
alias grfzf='git diff --name-only | fzf -m --print0 | xargs -0 -o -t git restore'
alias grsfzf='git diff --name-only | fzf -m --print0 | xargs -0 -o -t git restore --staged'
alias gf='git fetch'
alias gs='git status'
alias gss='git status -s'
alias gup='git fetch && git rebase'
alias gtd='git tag --delete'
alias gtdr='git tag --delete origin'
alias glo='git pull origin'
alias gl='git pull'
alias gb='git branch '
alias gbr='git branch -r'
alias gd='git diff'
alias gco='git checkout '
alias gcob='git checkout -b '
alias gcofzf='git branch | fzf | xargs git checkout'
alias gre='git remote'
alias gres='git remote show'
alias glgg='git log --graph --max-count=5 --decorate --pretty="oneline"'
alias gm='git merge'
alias gp='git push'
alias gpo='git push origin'
alias ggpush='git push origin $(current_branch)'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gcmnv='git commit --no-verify -m'
alias gcanenv='git commit --amend --no-edit --no-verify'

quick_commit() {
  local branch_name ticket_id commit_message push_flag
  branch_name=$(git branch --show-current)
  ticket_id=$(echo "$branch_name" | awk -F '-' '{print toupper($1"-"$2)}')
  commit_message="$ticket_id: $*"
  push_flag=$1

  if [[ "$push_flag" == "push" ]]; then
    commit_message="$ticket_id: ${*:2}"
    git commit --no-verify -m "$commit_message" && git push
  else
    git commit --no-verify -m "$commit_message"
  fi
}

alias gqc='quick_commit'
alias gqcp='quick_commit push'

poetry_run_nvim() {
  if command -v poetry >/dev/null 2>&1 && [ -f "poetry.lock" ]; then
    poetry run nvim "$@"
  else
    nvim "$@"
  fi
}
alias vi='poetry_run_nvim'
alias v='poetry_run_nvim'
alias nv='nvim'

# Folders
alias doc="cd $HOME/Documents"
alias dow="cd $HOME/Downloads"
alias h="cd $HOME"
alias ..="cd .."
alias z="cd $HOME/Developer/zeke"
alias tc="cd $HOME/Developer/tecclub.net"
alias conf="cd $HOME/.config"
alias notes="cd '$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault'"
alias bu="brew update && brew upgrade && brew cleanup && brew autoremove"

# Ranger
alias r=". ranger"

# Better ls
if command -v eza >/dev/null 2>&1; then
    alias ls="eza --all --icons=always"
fi

# Lazygit
alias lg="lazygit"

# Claude Code
alias cplan="claude --model opusplan"
alias cc="claude"

prompt() {
  local file
  file=$(ls "$HOME/prompts" 2>/dev/null | fzf)
  [ -n "$file" ] && cat "$HOME/prompts/$file"
}
