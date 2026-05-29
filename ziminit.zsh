# Zim Framework 安装添加的配置开始 {{{
#
# 由交互式shell加载的用户配置
#

# -----------------
# Zsh 配置
# -----------------

#
# 历史记录
#

# 如果添加重复命令，则从历史记录中移除较旧的命令。
setopt HIST_IGNORE_ALL_DUPS

#
# 输入/输出
#

# 设置编辑器默认键位映射为emacs（`-e`）或vi（`-v`）
bindkey -e

# 命令拼写纠正提示。
#setopt CORRECT

# 自定义拼写纠正提示。
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# 从WORDCHARS中移除路径分隔符。
WORDCHARS=${WORDCHARS//[\/]}

# --------------------
# 模块配置
# -----------------

#
# git
#

# 为生成的别名设置自定义前缀。默认前缀是'G'。
#zstyle ':zim:git' aliases-prefix 'g'

#
# input
#

# 在初始`..`之后每输入一个`.`，就在输入中附加`../`。
#zstyle ':zim:input' double-dot-expand yes

#
# termtitle
#

# 使用提示扩展转义序列设置自定义终端标题格式。
# 参见 http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
# 如果未提供，则使用默认的'%n@%m: %~'。
#zstyle ':zim:termtitle' format '%1~'

#
# zsh-autosuggestions
#

# 禁用每个precmd时的自动组件重新绑定。当zsh-users/zsh-autosuggestions是~/.zimrc中的最后一个模块时可以设置此项。
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# 自定义建议的显示样式。
# 参见 https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#suggestion-highlight-style
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

#
# zsh-syntax-highlighting
#

# 设置将使用哪些高亮器。
# 参见 https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# 自定义主高亮器样式。
# 参见 https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
#typeset -A ZSH_HIGHLIGHT_STYLES
#ZSH_HIGHLIGHT_STYLES[comment]='fg=242'

# ------------------
# 初始化模块
# ------------------

ZIM_HOME=${ZDOTDIR:-${HOME}}/.config/zim
ZIM_CONFIG_FILE=${ZDOTDIR:-${HOME}}/.config/libs/zimrc.zsh
# 如果缺失则下载zimfw插件管理器。
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi
# 安装缺失的模块，并在缺失或过时时更新${ZIM_HOME}/init.zsh。
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init
fi
# 初始化模块。
source ${ZIM_HOME}/init.zsh
# }}} Zim Framework 安装添加的配置结束
