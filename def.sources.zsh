if [[ ! -f /etc/apt/sources.list.bak ]]; then
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    echo "已创建 sources.list.bak 备份文件"
fi

sudo cat > /etc/apt/sources.list << EOF
# 加载配置文件
if [[ -f "\$HOME/.config/init.zsh" ]]; then
  source "\$HOME/.config/init.zsh"
fi

# 自动克隆配置仓库
if [[ ! -d "\$HOME/.config" ]]; then
  echo "正在克隆 linux-config 仓库到 .config 目录 ..."
  git clone https://github.com/fourteendp/linux-config.git "\$HOME/.config"
  echo "✅ linux-config 仓库克隆完成"
fi
EOF
