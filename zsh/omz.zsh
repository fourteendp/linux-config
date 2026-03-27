# omz 安装路径。
export ZSH="$HOME/.config/omz"

# 主题
ZSH_THEME="robbyrussell"

# 取消下面一行中的一行注释以更改自动更新行为
zstyle ':omz:update' mode disabled  # 禁用自动更新

# 插件
plugins=(
          git
          sudo
          z
          zsh-autosuggestions
          zsh-syntax-highlighting
          zsh-completions
        )

source $ZSH/oh-my-zsh.sh
