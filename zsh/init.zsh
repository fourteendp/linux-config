#!/usr/bin/env zsh
export ZSHCONFIG="$HOME/.config/zsh"

source $ZSHCONFIG/env.zsh          # 加载密钥
source $ZSHCONFIG/system.zsh       # 环境变量
source $ZSHCONFIG/apt.zsh          # 软件源

# 自动加载当前目录下lib中的所有.zsh脚本
for script in $ZSHCONFIG/lib/*.zsh; do
  if [[ -f $script ]]; then
    source $script
  fi
done
