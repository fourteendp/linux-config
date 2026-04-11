# 显示目录树的通用逻辑
_show_tree() {
    local level=$1
    local only_dirs=$2
    local default_level=$3
    local command_name=$4

    # 处理帮助信息请求：当用户输入 -h 或 --help 参数时，显示详细的命令使用说明
    if [[ $level == "-h" ]] || [[ $level == "--help" ]]; then
        echo "用法: ${command_name} [选项] [参数]"
        echo ""  # 空行，提高可读性
        echo "描述:"
        echo "  以树形结构显示目录内容"
        if [[ $command_name == "treed" ]]; then
            echo "  (仅显示目录，不显示文件)"
        fi
        echo ""  # 空行，提高可读性
        echo "参数:"
        echo "  [LEVEL]       指定显示的目录层级，默认为 ${default_level}"
        echo ""  # 空行，提高可读性
        echo "选项:"
        echo "  -h, --help    显示此帮助信息并退出"
        echo ""  # 空行，提高可读性
        echo "示例:"
        echo "  ${command_name}        # 以默认层级显示当前目录树"
        echo "  ${command_name} 3      # 显示3层深度的目录树"
        return 0
    fi

    # 参数验证
    if [[ -n $level && ! $level =~ ^[0-9]+$ ]]; then
        echo "错误：层级参数必须是正整数"
        echo "使用 '${command_name} --help' 查看帮助"
        return 1
    fi

    # 设置默认层级
    local final_level=${level:-${default_level}}

    # 构建并执行命令
    local eza_cmd="eza --tree -la --icons --git --level=${final_level} --sort=type"
    if [[ $only_dirs == "true" ]]; then
        eza_cmd="${eza_cmd} --only-dirs"
    fi

    eval $eza_cmd
}

# 显示完整目录树（包含文件）
function tree() {
    _show_tree "$1" "false" "2" "tree"
}

# 只显示目录的目录树
function treed() {
    _show_tree "$1" "true" "3" "treed"
}
