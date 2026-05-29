# 重新加载zsh配置
alias zshr="source ~/.zshrc"

if (($+commands[eza] )); then
  alias l='eza --icons=auto --git'
  alias la='eza -a --icons=auto --git'
  alias ll='eza -l --icons=auto --git --sort=type'
  alias lla='eza -la --icons=auto --git --sort=type'
fi

if (($+commands[z] )); then
  alias cd='z'
fi
