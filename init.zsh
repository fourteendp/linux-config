#!/usr/bin/env zsh
export CONFIGDIR="$HOME/.config"
export SOURCESDIR="$CONFIGDIR/sources"
export SCRIPTDIR="$CONFIGDIR/script"

source $CONFIGDIR/ziminit.zsh           # zimfw
source $CONFIGDIR/libs/env.zsh          # 加载密钥
source $CONFIGDIR/libs/system.zsh       # 环境变量
source $CONFIGDIR/libs/alias.zsh        # 别名
source $CONFIGDIR/func/init.zsh         # 函数
source $CONFIGDIR/libs/plugins.zsh      # 插件
source $CONFIGDIR/libs/work.zsh         # 工作相关
