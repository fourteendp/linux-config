# 设置错误处理
set -e
set -o pipefail

# 日志文件
LOG_FILE="$HOME/.log/install-openssh.log"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# 日志函数
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    case $level in
        "INFO")
            echo -e "\033[0;32m[$timestamp] INFO: $message\033[0m"
            ;;
        "WARN")
            echo -e "\033[0;33m[$timestamp] WARN: $message\033[0m"
            ;;
        "ERROR")
            echo -e "\033[0;31m[$timestamp] ERROR: $message\033[0m"
            ;;
        *)
            echo -e "[$timestamp] $message"
            ;;
    esac

    # 同时写入日志文件
    if [ ! -f "$LOG_FILE" ]; then
        mkdir -p "$(dirname "$LOG_FILE")"
        touch "$LOG_FILE"
    fi
    echo "[$timestamp] $level: $message" | sudo tee -a "$LOG_FILE" > /dev/null
}

# 错误处理函数
error_handler() {
    local exit_code=$?
    local line_number=$1
    log "ERROR" "脚本在第 $line_number 行出错，退出码: $exit_code"
    log "ERROR" "请检查日志文件: $LOG_FILE"
    exit $exit_code
}

# 设置错误陷阱
trap 'error_handler $LINENO' ERR

{
log "INFO" "========================================"
log "INFO" "OpenSSH 服务器安装与配置开始"
log "INFO" "========================================"

# 检查是否以 root 权限运行
if [ "$EUID" -eq 0 ]; then
    log "WARN" "请不要以 root 权限运行此脚本，脚本会使用 sudo 执行需要 root 权限的操作"
    log "WARN" "继续执行..."
fi

# 检测 systemd 是否可用
USE_SERVICE_CMD=false
if systemctl daemon-reload 2>/dev/null; then
    log "INFO" "systemd 可用，将使用 systemctl 命令管理服务"
else
    USE_SERVICE_CMD=true
    log "WARN" "systemd 不可用，将使用 service 命令管理服务"
fi

# 通用服务管理函数
service_manage() {
    local service_name="$1"
    local action="$2"

    case $action in
        "start")
            if [ "$USE_SERVICE_CMD" = true ]; then
                log "INFO" "使用 service 命令启动 $service_name 服务"
                if sudo service "$service_name" start; then
                    log "INFO" "✅ $service_name 服务已启动"
                    return 0
                else
                    log "ERROR" "启动 $service_name 服务失败"
                    return 1
                fi
            else
                log "INFO" "使用 systemctl 命令启动 $service_name 服务"
                if sudo systemctl start "$service_name"; then
                    log "INFO" "✅ $service_name 服务已启动"
                    return 0
                else
                    log "ERROR" "启动 $service_name 服务失败"
                    return 1
                fi
            fi
            ;;
        "restart")
            if [ "$USE_SERVICE_CMD" = true ]; then
                log "INFO" "使用 service 命令重启 $service_name 服务"
                if sudo service "$service_name" restart; then
                    log "INFO" "✅ $service_name 服务已重启"
                    return 0
                else
                    log "ERROR" "重启 $service_name 服务失败"
                    return 1
                fi
            else
                log "INFO" "使用 systemctl 命令重启 $service_name 服务"
                if sudo systemctl restart "$service_name"; then
                    log "INFO" "✅ $service_name 服务已重启"
                    return 0
                else
                    log "ERROR" "重启 $service_name 服务失败"
                    return 1
                fi
            fi
            ;;
        "stop")
            if [ "$USE_SERVICE_CMD" = true ]; then
                log "INFO" "使用 service 命令停止 $service_name 服务"
                if sudo service "$service_name" stop; then
                    log "INFO" "✅ $service_name 服务已停止"
                    return 0
                else
                    log "ERROR" "停止 $service_name 服务失败"
                    return 1
                fi
            else
                log "INFO" "使用 systemctl 命令停止 $service_name 服务"
                if sudo systemctl stop "$service_name"; then
                    log "INFO" "✅ $service_name 服务已停止"
                    return 0
                else
                    log "ERROR" "停止 $service_name 服务失败"
                    return 1
                fi
            fi
            ;;
        "status")
            if [ "$USE_SERVICE_CMD" = true ]; then
                log "INFO" "使用 service 命令检查 $service_name 服务状态"
                if sudo service "$service_name" status; then
                    log "INFO" "✅ $service_name 服务运行正常"
                    return 0
                else
                    log "ERROR" "❌ $service_name 服务未运行"
                    return 1
                fi
            else
                log "INFO" "使用 systemctl 命令检查 $service_name 服务状态"
                if sudo systemctl is-active --quiet "$service_name"; then
                    log "INFO" "✅ $service_name 服务运行正常"
                    return 0
                else
                    log "ERROR" "❌ $service_name 服务未运行"
                    return 1
                fi
            fi
            ;;
        "enable")
            if [ "$USE_SERVICE_CMD" = true ]; then
                log "INFO" "systemd 不可用，跳过 $service_name 服务开机自启设置"
                log "WARN" "建议在 /etc/rc.local 中添加启动命令"
                return 0
            else
                log "INFO" "使用 systemctl 命令设置 $service_name 服务开机自启"
                if sudo systemctl enable "$service_name"; then
                    log "INFO" "✅ $service_name 服务已设置为开机自启"
                    return 0
                else
                    log "ERROR" "设置 $service_name 服务开机自启失败"
                    return 1
                fi
            fi
            ;;
        *)
            log "ERROR" "未知的服务操作: $action"
            return 1
            ;;
    esac
}

# SSH 服务管理函数（兼容旧接口）
ssh_service_manage() {
    local action="$1"
    service_manage "ssh" "$action"
}

# 检查系统兼容性
if ! command -v apt &> /dev/null; then
    log "ERROR" "此脚本仅支持 Debian/Ubuntu 系统"
    exit 1
fi

# 检查网络连接
if ! sudo ping -c 1 -W 3 8.8.8.8 &> /dev/null; then
    log "WARN" "无法连接到网络，可能会跳过更新步骤"
fi

log "INFO" "正在安装 OpenSSH 服务器 ..."
if ! sudo apt update -y; then
    log "ERROR" "无法更新软件源"
    exit 1
fi
if ! sudo apt install -y openssh-server; then
    log "ERROR" "安装 openssh-server 失败"
    exit 1
fi
log "INFO" "✅ OpenSSH 服务器安装完成"

log "INFO" "========================================"
log "INFO" "配置 SSH 服务 ..."

# 备份原始配置文件
if [ ! -f /etc/ssh/sshd_config.bak ]; then
    log "INFO" "正在备份 SSH 配置文件 ..."
    if sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak; then
        log "INFO" "✅ SSH 配置文件备份完成"
    else
        log "ERROR" "备份 SSH 配置文件失败"
        exit 1
    fi
else
    log "INFO" "SSH 配置文件备份已存在"
fi

# 检查当前 SSH 配置
if [ -f /etc/ssh/sshd_config ]; then
    log "INFO" "当前 SSH 配置信息:"
    sudo grep -E "^(Port|ListenAddress|PermitRootLogin)" /etc/ssh/sshd_config | while read -r line; do
        log "INFO" "  $line"
    done
fi

# 生成新的 sshd_config 配置
log "INFO" "正在生成新的 SSH 配置文件 ..."
sudo tee /etc/ssh/sshd_config > /dev/null << 'EOF'
# OpenSSH 服务器配置文件
# 由 install-openssh.zsh 脚本自动生成
# 生成时间: TIMESTAMP_PLACEHOLDER

# 端口设置
Port 22

# 监听地址
ListenAddress 0.0.0.0

# 认证设置
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication yes
PermitEmptyPasswords no

# 安全设置
X11Forwarding no
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2

# 日志设置
SyslogFacility AUTH
LogLevel VERBOSE

# 会话设置
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes

# 拒绝不支持的协议
Protocol 2

# 主机密钥文件
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# 加密算法（安全）
KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256

# 限制访问（可选）
# AllowUsers admin
# DenyUsers root
EOF

# 替换时间戳占位符
sudo sed -i "s/TIMESTAMP_PLACEHOLDER/$TIMESTAMP/" /etc/ssh/sshd_config
log "INFO" "✅ SSH 配置文件已更新"

log "INFO" "========================================"
log "INFO" "生成 SSH 主机密钥 ..."

# 生成主机密钥
generate_host_key() {
    local key_type="$1"
    local key_file="$2"
    local bits="$3"

    if [ ! -f "$key_file" ]; then
        log "INFO" "正在生成 ${key_type} 主机密钥 ..."
        if sudo ssh-keygen -t "$key_type" -b "$bits" -f "$key_file" -N ""; then
            log "INFO" "✅ ${key_type} 主机密钥已生成"
        else
            log "ERROR" "生成 ${key_type} 主机密钥失败"
            exit 1
        fi
    else
        log "INFO" "✅ ${key_type} 主机密钥已存在"
    fi
}

generate_host_key "rsa" "/etc/ssh/ssh_host_rsa_key" "4096"
generate_host_key "ecdsa" "/etc/ssh/ssh_host_ecdsa_key" "521"
generate_host_key "ed25519" "/etc/ssh/ssh_host_ed25519_key" "256"

log "INFO" "========================================"
log "INFO" "重启/启动 SSH 服务 ..."

# 检查 SSH 服务状态并重启/启动
if [ "$USE_SERVICE_CMD" = true ]; then
    log "INFO" "systemd 不可用，尝试使用 service 命令"
    # 在 systemd 不可用环境中直接尝试启动服务
    if sudo service ssh status &> /dev/null; then
        ssh_service_manage "restart"
    else
        ssh_service_manage "start"
    fi
else
    # 在 systemd 可用环境中使用 systemctl
    if sudo systemctl is-active --quiet ssh; then
        ssh_service_manage "restart"
    else
        ssh_service_manage "start"
    fi
fi

log "INFO" "========================================"
log "INFO" "启用 SSH 服务开机自启 ..."

ssh_service_manage "enable"

log "INFO" "========================================"
log "INFO" "检查 SSH 服务状态 ..."

if ssh_service_manage "status"; then
    log "INFO" "端口: 22"
    log "INFO" "状态: 运行中"

    # 显示详细的服务状态
    log "INFO" "详细状态:"
    if [ "$USE_SERVICE_CMD" = true ]; then
        sudo service ssh status 2>&1 | while read -r line; do
            log "INFO" "  $line"
        done
    else
        sudo systemctl status ssh 2>&1 | while read -r line; do
            log "INFO" "  $line"
        done
    fi
else
    log "ERROR" "请检查配置:"
    if [ "$USE_SERVICE_CMD" = true ]; then
        log "ERROR" "  检查 SSH 配置: sudo service ssh status"
        log "ERROR" "  检查日志: sudo journalctl -u ssh 或 /var/log/auth.log"
    else
        log "ERROR" "  检查配置: sudo journalctl -u ssh"
    fi
    exit 1
fi

log "INFO" "========================================"
log "INFO" "验证 SSH 配置 ..."

# 验证配置文件语法
if sudo sshd -t; then
    log "INFO" "✅ SSH 配置文件语法正确"
else
    log "ERROR" "SSH 配置文件语法错误"
    exit 1
fi

# 测试 SSH 连接（本地）
log "INFO" "测试本地 SSH 连接..."
if ssh -o BatchMode=yes -o ConnectTimeout=3 localhost exit 2>/dev/null; then
    log "INFO" "✅ 本地 SSH 连接测试成功"
else
    log "INFO" "本地 SSH 连接测试跳过（可能需要密码认证）"
fi

log "INFO" "========================================"
log "INFO" "增强 SSH 安全设置 ..."

# 创建用户 SSH 目录
log "INFO" "配置用户 SSH 目录 ..."
USER_HOME=$(eval echo "~$USER")
USER_SSH_DIR="$USER_HOME/.ssh"

if [ ! -d "$USER_SSH_DIR" ]; then
    mkdir -p "$USER_SSH_DIR"
    chmod 700 "$USER_SSH_DIR"
    log "INFO" "✅ 用户 SSH 目录已创建: $USER_SSH_DIR"
else
    log "INFO" "✅ 用户 SSH 目录已存在: $USER_SSH_DIR"
fi

# 生成用户密钥对
log "INFO" "生成用户 SSH 密钥对 ..."
if [ ! -f "$USER_SSH_DIR/id_ed25519" ]; then
    if ssh-keygen -t ed25519 -f "$USER_SSH_DIR/id_ed25519" -N "" -C "$USER@$(hostname)"; then
        log "INFO" "✅ Ed25519 用户密钥已生成"
        log "INFO" "  公钥位置: $USER_SSH_DIR/id_ed25519.pub"
        log "INFO" "  私钥位置: $USER_SSH_DIR/id_ed25519"
    else
        log "WARN" "生成用户密钥失败，跳过此步骤"
    fi
else
    log "INFO" "✅ 用户密钥已存在"
fi

# 添加公钥到授权列表
if [ -f "$USER_SSH_DIR/id_ed25519.pub" ]; then
    log "INFO" "添加公钥到 authorized_keys ..."
    if [ ! -f "$USER_SSH_DIR/authorized_keys" ]; then
        cp "$USER_SSH_DIR/id_ed25519.pub" "$USER_SSH_DIR/authorized_keys"
        chmod 600 "$USER_SSH_DIR/authorized_keys"
        log "INFO" "✅ authorized_keys 文件已创建"
    else
        if ! grep -qF "$(cat "$USER_SSH_DIR/id_ed25519.pub")" "$USER_SSH_DIR/authorized_keys"; then
            cat "$USER_SSH_DIR/id_ed25519.pub" >> "$USER_SSH_DIR/authorized_keys"
            log "INFO" "✅ 公钥已添加到 authorized_keys"
        else
            log "INFO" "✅ 公钥已在 authorized_keys 中"
        fi
    fi
fi

# 设置正确的权限
log "INFO" "设置 SSH 目录权限 ..."
chmod 700 "$USER_SSH_DIR"
chmod 600 "$USER_SSH_DIR/id_ed25519" 2>/dev/null || true
chmod 644 "$USER_SSH_DIR/id_ed25519.pub" 2>/dev/null || true
chmod 600 "$USER_SSH_DIR/authorized_keys" 2>/dev/null || true

# 配置防火墙（如果可用）
log "INFO" "配置防火墙规则 ..."
if command -v ufw &> /dev/null; then
    log "INFO" "检测到 UFW 防火墙"
    if sudo ufw status | grep -q "inactive"; then
        log "WARN" "UFW 防火墙未启用"
        log "WARN" "建议启用: sudo ufw enable"
    else
        # 允许 SSH 端口
        if sudo ufw allow ssh; then
            log "INFO" "✅ 已添加 SSH 防火墙规则"
        else
            log "WARN" "添加 SSH 防火墙规则失败"
        fi
    fi
elif command -v firewall-cmd &> /dev/null; then
    log "INFO" "检测到 firewalld 防火墙"
    if sudo firewall-cmd --state &> /dev/null; then
        if sudo firewall-cmd --permanent --add-service=ssh; then
            sudo firewall-cmd --reload
            log "INFO" "✅ 已添加 SSH 防火墙规则"
        else
            log "WARN" "添加 SSH 防火墙规则失败"
        fi
    else
        log "WARN" "firewalld 未运行"
    fi
else
    log "INFO" "未检测到防火墙，跳过防火墙配置"
fi

# 安装 fail2ban（可选）
log "INFO" "fail2ban 安装检查 ..."
if command -v fail2ban-client &> /dev/null; then
    log "INFO" "✅ fail2ban 已安装"

    # 配置 fail2ban
    if [ ! -f /etc/fail2ban/jail.local ]; then
        log "INFO" "创建 fail2ban 配置文件 ..."
        sudo tee /etc/fail2ban/jail.local > /dev/null << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
backend = systemd

[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
EOF
        log "INFO" "✅ fail2ban 配置文件已创建"
    fi

    # 重启 fail2ban
    if service_manage "fail2ban" "restart"; then
        log "INFO" "✅ fail2ban 服务已重启"
    else
        log "WARN" "重启 fail2ban 服务失败"
    fi
else
    log "INFO" "fail2ban 未安装"
    log "WARN" "建议安装 fail2ban 防暴力破解: sudo apt install fail2ban"
fi

# 创建 SSH 配置脚本
log "INFO" "创建 SSH 辅助脚本 ..."
SSH_SCRIPTS_DIR="$USER_HOME/.config/script/ssh"
mkdir -p "$SSH_SCRIPTS_DIR"

# 创建 SSH 连接脚本
cat > "$SSH_SCRIPTS_DIR/connect.sh" << 'EOF'
#!/bin/bash
# SSH 快速连接脚本

HOST="${1:-localhost}"
PORT="${2:-22}"
USER="${3:-$USER}"

echo "连接到 $USER@$HOST:$PORT ..."
ssh -p "$PORT" "$USER@$HOST"
EOF
chmod +x "$SSH_SCRIPTS_DIR/connect.sh"

# 创建 SSH 密钥管理脚本
cat > "$SSH_SCRIPTS_DIR/keys.sh" << 'EOF'
#!/bin/bash
# SSH 密钥管理脚本

case "$1" in
    "list")
        echo "已有的 SSH 密钥:"
        ls -la ~/.ssh/id_* 2>/dev/null || echo "没有找到密钥"
        ;;
    "generate")
        KEY_TYPE="${2:-ed25519}"
        KEY_NAME="${3:-id_$KEY_TYPE}"
        echo "生成 $KEY_TYPE 密钥对..."
        ssh-keygen -t "$KEY_TYPE" -f ~/.ssh/"$KEY_NAME" -N ""
        echo "密钥已生成:"
        echo "  私钥: ~/.ssh/$KEY_NAME"
        echo "  公钥: ~/.ssh/$KEY_NAME.pub"
        ;;
    "add")
        if [ -f ~/.ssh/id_ed25519.pub ]; then
            cat ~/.ssh/id_ed25519.pub
            echo ""
            echo "复制上面的公钥到远程服务器的 ~/.ssh/authorized_keys 文件"
        else
            echo "没有找到公钥，请先生成密钥对"
        fi
        ;;
    *)
        echo "用法: $0 [list|generate|add]"
        echo "  list    - 列出所有 SSH 密钥"
        echo "  generate [类型] [名称] - 生成新的密钥对"
        echo "  add     - 显示公钥用于添加到远程服务器"
        ;;
esac
EOF
chmod +x "$SSH_SCRIPTS_DIR/keys.sh"

log "INFO" "✅ SSH 辅助脚本已创建"
log "INFO" "  连接脚本: $SSH_SCRIPTS_DIR/connect.sh"
log "INFO" "  密钥管理: $SSH_SCRIPTS_DIR/keys.sh"

log "INFO" "========================================"
log "INFO" "OpenSSH 服务器配置完成！"
log "INFO" "========================================"
log "INFO" "SSH 配置信息:"
log "INFO" "  端口: 22"
log "INFO" "  监听: 0.0.0.0"
log "INFO" "  Root 登录: 禁止"
log "INFO" "  密码认证: 允许"
log "INFO" "  公钥认证: 允许"
log "INFO" "  日志文件: /var/log/auth.log"
log "INFO" "  用户密钥: $USER_SSH_DIR/id_ed25519"
log "INFO" "========================================"
log "INFO" "安全功能:"
log "INFO" "✅ 已禁用 root 登录"
log "INFO" "✅ 已启用公钥认证"
log "INFO" "✅ 已限制最大尝试次数: 3"
log "INFO" "✅ 已设置会话超时: 300秒"
log "INFO" "✅ 已生成强加密算法配置"
log "INFO" "✅ 已生成用户密钥对"
log "INFO" "✅ 已配置 SSH 目录权限"
log "INFO" "========================================"
log "INFO" "使用说明:"
log "INFO" "1. 使用密钥认证连接: ssh -i ~/.ssh/id_ed25519 user@host"
log "INFO" "2. 使用辅助脚本: ~/.config/script/ssh/connect.sh [host] [port] [user]"
log "INFO" "3. 管理密钥: ~/.config/script/ssh/keys.sh [list|generate|add]"
log "INFO" "========================================"
log "INFO" "安全建议:"
log "INFO" "1. 尽快禁用密码认证: 修改 /etc/ssh/sshd_config 中 PasswordAuthentication no"
log "INFO" "2. 定期更新系统: sudo apt update && sudo apt upgrade"
log "INFO" "3. 监控日志: sudo tail -f /var/log/auth.log"
log "INFO" "4. 安装 fail2ban: sudo apt install fail2ban"
log "INFO" "5. 配置防火墙: sudo ufw allow ssh && sudo ufw enable"
log "INFO" "========================================"
log "INFO" "日志文件: $LOG_FILE"
log "INFO" "========================================"
}
