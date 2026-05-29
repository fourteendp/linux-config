# 环境变量
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export MANPATH="/usr/local/man:$MANPATH"

# 你可能需要手动设置你的语言环境中文
export LANG=zh_CN.UTF-8
export LANGUAGE=
export LC_CTYPE="zh_CN.UTF-8"
export LC_NUMERIC="zh_CN.UTF-8"
export LC_TIME="zh_CN.UTF-8"
export LC_COLLATE="zh_CN.UTF-8"
export LC_MONETARY="zh_CN.UTF-8"
export LC_MESSAGES="zh_CN.UTF-8"
export LC_PAPER="zh_CN.UTF-8"
export LC_NAME="zh_CN.UTF-8"
export LC_ADDRESS="zh_CN.UTF-8"
export LC_TELEPHONE="zh_CN.UTF-8"
export LC_MEASUREMENT="zh_CN.UTF-8"
export LC_IDENTIFICATION="zh_CN.UTF-8"
export LC_ALL=zh_CN.UTF-8

# 编译标志
export ARCHFLAGS="-arch $(uname -m)"

# 本地和远程会话的首选编辑器
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='nvim'
fi
