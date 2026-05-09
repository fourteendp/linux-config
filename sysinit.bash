{
echo "========================================"
echo "正在更新软件源 ..."
apt update -y
echo "✅ 软件源更新完成"

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
chown admin:admin /home/admin/.zshrc
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
