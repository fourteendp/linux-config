# 重新加载zsh配置
alias zshr="source ~/.zshrc"



if (($+commands[eza] )); then
  # ls 命令
  alias ls='eza -a --icons=auto'  # 自动判断是否是否显示图标（非纯文本环境）
  alias l='eza -1a --icons'     # 单列显示，带图标

  # 详细列表模式
  alias ll='eza -l --icons --git --sort=type'  # 详细信息 + 图标 + Git 状态
  alias la='eza -la --icons --git --sort=type' # 包含隐藏文件的详细列表
  alias laa='eza -la --icons --git  --sort=type --total-size' # 包含隐藏文件的详细列表，按类型排序
  alias l.='eza -ld .* --icons --git --sort=type'    # 只显示隐藏文件/目录
fi

if (($+commands[z] )); then
  alias cd='z'
fi
