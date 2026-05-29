#
# 此文件不在shell启动时加载，仅用于配置zimfw。
#

#
# 模块
#

# 设置合理的Zsh内置环境选项。
zmodule environment
# 提供便捷的git别名和函数。
zmodule git
# 为输入事件应用正确的绑定键。
zmodule input
# 设置自定义终端标题。
zmodule termtitle
# 实用别名和函数。为ls、grep和less添加颜色。
zmodule utility
# 提供按两下ESC键在命令前添加sudo的功能。
zmodule ohmyzsh/ohmyzsh --root plugins/sudo

# <-- 通常新模块应添加在此处。请检查每个模块的文档以了解注意事项。

#
# 提示
#

# 向提示暴露上一个命令的运行时长。
zmodule duration-info
# 向提示暴露git仓库状态信息。
zmodule git-info
# Spaceship和Starship提示的极简ASCII版本。
zmodule asciiship

#
# 补全
#

# Zsh的额外补全定义。
zmodule zsh-users/zsh-completions --fpath src
# 启用并配置智能且广泛的Tab补全，必须在添加补全定义的所有模块之后加载。
zmodule completion

#
# 必须最后初始化的模块
#

# 类似Fish的Zsh语法高亮，必须在补全之后加载。
zmodule zsh-users/zsh-syntax-highlighting
# 类似Fish的Zsh历史搜索，必须在zsh-users/zsh-syntax-highlighting之后加载。
zmodule zsh-users/zsh-history-substring-search
# 类似Fish的Zsh自动建议。将以下内容添加到您的~/.zshrc中以提高性能：
# ZSH_AUTOSUGGEST_MANUAL_REBIND=1
zmodule zsh-users/zsh-autosuggestions
