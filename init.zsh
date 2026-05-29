#!/usr/bin/env zsh
export CONFIGDIR="$HOME/.config"
export SOURCESDIR="$CONFIGDIR/sources"

# source "$HOME/.config/ziminit.zsh"

source $CONFIGDIR/libs/env.zsh          # 加载密钥
source $CONFIGDIR/libs/system.zsh       # 环境变量
source $CONFIGDIR/libs/alias.zsh        # 别名
source $CONFIGDIR/libs/functions.zsh    # 函数
source $CONFIGDIR/libs/plugins.zsh      # 插件
