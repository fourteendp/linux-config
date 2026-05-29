function aptsource() {
  if [[ ! -f /etc/apt/sources.list.bak ]]; then
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    echo "已创建 sources.list.bak 备份文件"
  fi

  local files=($(ls $SOURCESDIR))

  if [[ ${#files[@]} -eq 0 ]]; then
    echo "错误：$SOURCESDIR 目录中没有镜像源文件"
    return 1
  fi

  echo "可用的镜像源："
  select file in "${files[@]}" "exit"; do
    if [[ "$file" == "exit" ]]; then
      echo "操作已取消"
      return 0
    elif [[ -n "$file" ]]; then
      # 复制选择的镜像源文件到 /etc/apt/sources.list
      sudo cp "$SOURCESDIR/$file" /etc/apt/sources.list
      if [[ $? -eq 0 ]]; then
        echo "已成功更换镜像源为：$file"

        # 更新包缓存
        echo "正在更新包缓存..."
        sudo apt update
        if [[ $? -eq 0 ]]; then
          echo "包缓存更新成功"
        else
          echo "警告：包缓存更新失败"
        fi
      else
        echo "错误：无法复制镜像源文件"
      fi
      break
    else
      echo "无效的选择，请重新选择"
    fi
  done
}

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

# 设置代理
proxy() {
    local action="${1:-status}"
    local proxy_addr="${2:-http://127.0.0.1:7897}"

    case "$action" in
        on|set)
            # 设置系统代理
            export http_proxy="$proxy_addr"
            export https_proxy="$proxy_addr"
            export all_proxy="$proxy_addr"
            export HTTP_PROXY="$proxy_addr"
            export HTTPS_PROXY="$proxy_addr"
            export ALL_PROXY="$proxy_addr"

            # 设置代理排除项
            export no_proxy="localhost,127.0.0.1,::1"
            export NO_PROXY="$no_proxy"

            # 配置 Git 代理
            git config --global http.proxy "$proxy_addr"
            git config --global https.proxy "$proxy_addr"

            # 配置 npm 代理
            npm config set proxy "$proxy_addr" 2>/dev/null
            npm config set https-proxy "$proxy_addr" 2>/dev/null

            # 配置 pip 代理
            mkdir -p ~/.config/pip
            cat > ~/.config/pip/pip.conf << EOF
[global]
proxy = $proxy_addr

[install]
use-feature = 2020-resolver
EOF

            echo "✅ 代理已开启: $proxy_addr"
            echo "   环境变量: http_proxy, https_proxy, all_proxy"
            echo "   Git 代理: 已配置"
            echo "   npm 代理: 已配置"
            echo "   pip 代理: 已配置"
            ;;
        off|unset)
            # 取消系统代理
            unset http_proxy https_proxy all_proxy
            unset HTTP_PROXY HTTPS_PROXY ALL_PROXY
            unset no_proxy NO_PROXY

            # 取消 Git 代理
            git config --global --unset http.proxy 2>/dev/null
            git config --global --unset https.proxy 2>/dev/null

            # 取消 npm 代理
            npm config delete proxy 2>/dev/null
            npm config delete https-proxy 2>/dev/null

            # 取消 pip 代理
            rm -f ~/.config/pip/pip.conf

            echo "✅ 代理已关闭"
            echo "   环境变量: 已清除"
            echo "   Git 代理: 已移除"
            echo "   npm 代理: 已移除"
            echo "   pip 代理: 已移除"
            ;;
        status|check)
            echo "🔍 代理状态检查:"
            echo ""

            # 检查环境变量
            if [[ -n "$http_proxy" ]] || [[ -n "$HTTP_PROXY" ]]; then
                echo "   ✅ http_proxy: ${http_proxy:-$HTTP_PROXY}"
            else
                echo "   ❌ http_proxy: 未设置"
            fi

            if [[ -n "$https_proxy" ]] || [[ -n "$HTTPS_PROXY" ]]; then
                echo "   ✅ https_proxy: ${https_proxy:-$HTTPS_PROXY}"
            else
                echo "   ❌ https_proxy: 未设置"
            fi

            if [[ -n "$all_proxy" ]] || [[ -n "$ALL_PROXY" ]]; then
                echo "   ✅ all_proxy: ${all_proxy:-$ALL_PROXY}"
            else
                echo "   ❌ all_proxy: 未设置"
            fi

            # 检查 Git 代理
            local git_proxy=$(git config --global http.proxy 2>/dev/null)
            if [[ -n "$git_proxy" ]]; then
                echo "   ✅ Git 代理: $git_proxy"
            else
                echo "   ❌ Git 代理: 未设置"
            fi

            # 检查 npm 代理
            local npm_proxy=$(npm config get proxy 2>/dev/null)
            if [[ -n "$npm_proxy" ]] && [[ "$npm_proxy" != "undefined" ]]; then
                echo "   ✅ npm 代理: $npm_proxy"
            else
                echo "   ❌ npm 代理: 未设置"
            fi

            # 检查 pip 代理
            if [[ -f ~/.config/pip/pip.conf ]]; then
                local pip_proxy=$(grep -i "proxy" ~/.config/pip/pip.conf | cut -d'=' -f2 | tr -d ' ')
                if [[ -n "$pip_proxy" ]]; then
                    echo "   ✅ pip 代理: $pip_proxy"
                else
                    echo "   ❌ pip 代理: 配置文件存在但未设置代理"
                fi
            else
                echo "   ❌ pip 代理: 未设置"
            fi
            ;;
        test)
            echo "🧪 测试代理连接..."
            if [[ -z "$http_proxy" ]] && [[ -z "$HTTP_PROXY" ]]; then
                echo "❌ 代理未设置，请先运行: proxy on"
                return 1
            fi

            # 测试 HTTP 代理
            echo "测试 HTTP 代理..."
            if curl -I --connect-timeout 5 --max-time 10 http://www.google.com 2>/dev/null | grep -q "HTTP/"; then
                echo "✅ HTTP 代理连接正常"
            else
                echo "❌ HTTP 代理连接失败"
            fi

            # 测试 HTTPS 代理
            echo "测试 HTTPS 代理..."
            if curl -I --connect-timeout 5 --max-time 10 https://www.google.com 2>/dev/null | grep -q "HTTP/"; then
                echo "✅ HTTPS 代理连接正常"
            else
                echo "❌ HTTPS 代理连接失败"
            fi
            ;;
        help|--help|-h)
            echo "代理管理函数"
            echo ""
            echo "用法: proxy [命令] [地址]"
            echo ""
            echo "命令:"
            echo "  on [地址]     开启代理 (默认: http://127.0.0.1:7897)"
            echo "  off           关闭代理"
            echo "  status        显示代理状态"
            echo "  test          测试代理连接"
            echo "  help          显示此帮助信息"
            echo ""
            echo "示例:"
            echo "  proxy on                    # 使用默认代理地址"
            echo "  proxy on http://proxy:8080  # 使用自定义代理地址"
            echo "  proxy off                   # 关闭代理"
            echo "  proxy status                # 查看状态"
            echo "  proxy test                  # 测试连接"
            ;;
        *)
            echo "未知命令: $action"
            echo "使用 'proxy help' 查看帮助"
            return 1
            ;;
    esac
}

# 快捷代理函数
proxy_on() {
    proxy on "${1:-http://127.0.0.1:7897}"
}

proxy_off() {
    proxy off
}

proxy_status() {
    proxy status
}

# 为特定工具设置代理的函数
proxy_git() {
    local proxy_addr="${1:-http://127.0.0.1:7897}"

    if [[ "$1" == "off" ]]; then
        git config --global --unset http.proxy 2>/dev/null
        git config --global --unset https.proxy 2>/dev/null
        echo "✅ Git 代理已移除"
    else
        git config --global http.proxy "$proxy_addr"
        git config --global https.proxy "$proxy_addr"
        echo "✅ Git 代理已设置: $proxy_addr"
    fi
}

proxy_docker() {
    local proxy_addr="${1:-http://127.0.0.1:7897}"

    if [[ "$1" == "off" ]]; then
        # 恢复 Docker 默认配置
        sudo rm -f /etc/systemd/system/docker.service.d/http-proxy.conf
        sudo systemctl daemon-reload
        sudo systemctl restart docker
        echo "✅ Docker 代理已移除"
    else
        # 创建代理配置目录
        sudo mkdir -p /etc/systemd/system/docker.service.d

        # 创建代理配置文件
        sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf > /dev/null <<EOF
[Service]
Environment="HTTP_PROXY=$proxy_addr"
Environment="HTTPS_PROXY=$proxy_addr"
Environment="NO_PROXY=localhost,127.0.0.1"
EOF

        # 重新加载配置并重启 Docker
        sudo systemctl daemon-reload
        sudo systemctl restart docker
        echo "✅ Docker 代理已设置: $proxy_addr"
    fi
}

# 代理配置文件函数
proxy_config() {
    local config_file="$HOME/.proxy.conf"

    case "$1" in
        show)
            if [[ -f "$config_file" ]]; then
                cat "$config_file"
            else
                echo "配置文件不存在: $config_file"
            fi
            ;;
        set)
            if [[ -z "$2" ]]; then
                echo "用法: proxy config set <代理地址>"
                return 1
            fi
            echo "PROXY_ADDR=$2" > "$config_file"
            echo "✅ 代理配置已保存: $config_file"
            ;;
        apply)
            if [[ -f "$config_file" ]]; then
                source "$config_file"
                proxy on "$PROXY_ADDR"
            else
                echo "配置文件不存在，请先设置: proxy config set <地址>"
            fi
            ;;
        *)
            echo "用法: proxy config [show|set|apply]"
            ;;
    esac
}
