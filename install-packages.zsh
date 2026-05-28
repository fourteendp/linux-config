#!/usr/bin/env zsh
# 自动检测并安装 userinit.zsh 中列出的软件包

set -e

PACKAGES=(
    zsh git curl wget eza zoxide fzf starship neovim axel rsync unzip ranger
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
