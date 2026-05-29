# 脚本注册表
typeset -A SCRIPTS
SCRIPTS=(
    [init-system]="$CONFIGDIR/script/init-system.bash"
    [install-openssh]="$CONFIGDIR/script/install-openssh.zsh"
    [install-packages]="$CONFIGDIR/script/install-packages.zsh"
)

# 运行指定脚本
scriptrun() {
    local script_name="$1"
    shift

    if [[ -z "$script_name" ]]; then
        echo "用法: scriptrun <脚本名称> [参数...]"
        echo ""
        echo "可用的脚本:"
        scriptlist
        return 1
    fi

    if [[ -z "${SCRIPTS[$script_name]}" ]]; then
        echo "错误: 未找到脚本 '$script_name'"
        echo ""
        echo "可用的脚本:"
        scriptlist
        return 1
    fi

    local script_path="${SCRIPTS[$script_name]}"

    if [[ ! -f "$script_path" ]]; then
        echo "错误: 脚本文件不存在: $script_path"
        return 1
    fi

    echo "正在运行脚本: $script_name"
    echo "脚本路径: $script_path"
    echo ""

    # 根据文件扩展名选择解释器
    case "$script_path" in
        *.zsh)
            zsh "$script_path" "$@"
            ;;
        *.bash|*.sh)
            bash "$script_path" "$@"
            ;;
        *)
            # 尝试使用文件中的 shebang
            if [[ -x "$script_path" ]]; then
                "$script_path" "$@"
            else
                echo "错误: 无法确定脚本解释器，请为脚本添加执行权限或使用 .zsh/.bash 扩展名"
                return 1
            fi
            ;;
    esac
}

# 列出所有注册的脚本
scriptlist() {
    echo "已注册的脚本:"
    for name in ${(k)SCRIPTS}; do
        local script_path="${SCRIPTS[$name]}"
        local script_status="✅"
        if [[ ! -f "$script_path" ]]; then
            script_status="❌ 文件不存在"
        elif [[ ! -x "$script_path" ]] && [[ "$script_path" != *.zsh && "$script_path" != *.bash ]]; then
            script_status="⚠️ 无执行权限"
        fi
        echo "  $script_status $name -> $script_path"
    done
}
