#!/usr/bin/env zsh
set -e

PACKAGES=(
    zsh           # Zsh shell, 强大的交互式 shell
    git           # 版本控制系统
    curl          # 命令行数据传输工具
    wget          # 网络文件下载工具
    eza           # 现代化的 ls 命令替代品，支持图标和 Git 状态
    zoxide        # 智能的 cd 命令替代品，支持历史记录和 frecency
    fzf           # 模糊查找器，用于文件、历史记录、进程等的交互式筛选
    starship      # 跨平台的 shell 提示符，显示丰富的上下文信息
    neovim        # 现代化的 Vim 文本编辑器
    axel          # 多线程下载加速器
    rsync         # 快速、多功能的文件同步和复制工具
    ranger        # 终端下的文件管理器，支持预览
    p7zip-full    # 7-Zip 压缩工具，支持多种格式
)

echo "========================================"
echo "📦 检测软件包安装状态..."
echo "========================================"

# 存储未安装的软件包
MISSING=()

for pkg in "${PACKAGES[@]}"; do
    if command -v "$pkg" >/dev/null 2>&1 || dpkg -s "$pkg" >/dev/null 2>&1; then
        echo "✅ $pkg: 已安装"
    else
        echo "❌ $pkg: 未安装"
        MISSING+=("$pkg")
    fi
done

echo ""
if [[ ${#MISSING[@]} -eq 0 ]]; then
    echo "🎉 所有软件包均已安装，无需操作。"
    exit 0
fi

echo "========================================"
echo "📥 开始安装缺失的软件包..."
echo "========================================"

echo "缺失的软件包: ${MISSING[*]}"
echo ""

# 使用 sudo apt 安装
sudo apt update -y
sudo apt install -y "${MISSING[@]}"

echo ""
echo "========================================"
echo "✅ 安装完成！"
echo "========================================"

# 验证安装
echo "再次检测安装状态:"
for pkg in "${MISSING[@]}"; do
    if command -v "$pkg" >/dev/null 2>&1 || dpkg -s "$pkg" >/dev/null 2>&1; then
        echo "✅ $pkg: 已安装"
    else
        echo "⚠️  $pkg: 安装失败"
    fi
done
