{
echo "========================================"
echo "WSL 设置 ..."
cat > /etc/wsl.conf << EOF
[boot]
systemd=false
[network]
generateResolvConf = false
EOF
echo "✅ WSL 设置完成"

echo "========================================"
echo "网络设置 ..."
cat > /etc/resolv.conf << EOF
nameserver 223.5.5.5
nameserver 223.6.6.6
nameserver 8.8.8.8
EOF
echo "✅ 网络设置完成"

echo "========================================"
echo "设置镜像源 ..."
if [ ! -f /etc/apt/sources.list.bak ]; then
    echo "正在备份镜像源 ..."
    cp /etc/apt/sources.list /etc/apt/sources.list.bak
    echo "✅ 镜像源备份完成"
fi
cat > /etc/apt/sources.list << EOF
# 默认注释了源码仓库，如有需要可自行取消注释
deb http://mirrors.ustc.edu.cn/debian trixie main contrib non-free non-free-firmware
# deb-src http://mirrors.ustc.edu.cn/debian trixie main contrib non-free non-free-firmware
deb http://mirrors.ustc.edu.cn/debian trixie-updates main contrib non-free non-free-firmware
# deb-src http://mirrors.ustc.edu.cn/debian trixie-updates main contrib non-free non-free-firmware

# backports 软件源，请按需启用
# deb http://mirrors.ustc.edu.cn/debian trixie-backports main contrib non-free non-free-firmware
# deb-src http://mirrors.ustc.edu.cn/debian trixie-backports main contrib non-free non-free-firmware
EOF
echo "✅ 镜像源设置完成"

echo "========================================"
echo "正在更新软件源 ..."
apt update -y
echo "✅ 软件源更新完成"

echo "========================================"
echo "安装必要工具 ..."
apt install -y git zsh
echo "✅ 必要工具安装完成"

echo "========================================"
echo "正在设置 root 密码为 root ..."
passwd root << EOF
root
root
EOF
echo "✅ root 密码设置完成"


echo "========================================"
if ! id -u admin > /dev/null 2>&1; then
    echo "正在创建 admin 用户 ..."
    useradd -m -s /bin/bash admin
    passwd admin << EOF
admin
admin
EOF
    usermod -aG sudo admin
    echo "✅ admin 用户创建成功"
    echo "🔑 用户名: admin  密码: admin"
else
    echo "✅ admin 用户已存在"
fi

echo "========================================"
echo "设置 admin 用户 zsh ..."
touch /home/admin/.zshrc
cat > /home/admin/.zshrc << EOF
if [[ ! -d "\$HOME/.config" ]]; then
  git clone https://github.com/fourteendp/linux-config.git "\$HOME/.config"
fi

source "\$HOME/.config/init.zsh"
EOF
chown admin:admin /home/admin/.zshrc
touch /home/admin/.zshenv
cat > /home/admin/.zshenv << EOF
skip_global_compinit=1
EOF
chown admin:admin /home/admin/.zshenv
echo "✅ admin 用户 zsh 设置完成"

echo "========================================"
echo "正在设置 admin 默认 Shell 为 zsh ..."
chsh -s $(which zsh) admin
echo "✅ admin 默认 Shell 已切换为 zsh"

echo "========================================"
echo "🎉 所有初始化操作全部完成！"
echo "========================================"
echo "root  密码: root"
echo "admin 密码: admin"
echo "admin 默认 Shell: zsh"
echo "========================================"
echo ""
echo "正在切换到 admin 用户 ..."
echo ""

su - admin
}
