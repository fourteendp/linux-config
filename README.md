
# Linux命令行工具大全

本文将**传统核心工具**与**现代高效替代品**全面整合，按15大类别系统梳理，覆盖日常使用、开发、运维全场景，帮助你构建完整的命令行技能体系。

---
## 中文环境
```bash
apt install locales
dpkg-reconfigure locales
```
## 编译环境
```bash
apt install build-essential
```

## 一、基础系统与环境工具

| 工具 | 功能 | 核心用法 | 现代替代 |
|------|------|----------|----------|
| **uname** | 查看系统信息 | `uname -a`(完整信息)、`uname -r`(内核版本) | 无，基础必备 |
| **uptime** | 系统运行时间与负载 | `uptime` | 无，极简显示 |
| **date** | 日期时间管理 | `date "+%Y-%m-%d %H:%M:%S"` | 无，系统基础 |
| **cal** | 日历显示 | `cal`(当月)、`cal 2026`(全年) | 无，轻量实用 |
| **hostname** | 主机名管理 | `hostname`(查看)、`hostnamectl set-hostname newname`(设置) | 无，系统标识 |
| **env** | 环境变量管理 | `env`(查看所有)、`echo $PATH`(查看单个) | 无，基础工具 |
| **history** | 命令历史记录 | `history`(查看)、`!100`(执行第100条) | **atuin**(云同步、模糊搜索) |
| **clear** | 清屏 | `clear` | 无，终端基础 |

---

## 二、文件与目录管理（核心高频）

### 2.1 基础操作工具
| 工具 | 功能 | 核心用法 | 现代替代 |
|------|------|----------|----------|
| **ls** | 列出目录内容 | `ls -l`(详细)、`ls -a`(显示隐藏) | **eza**(图标、Git状态、树视图) |
| **cd** | 切换目录 | `cd ~`(回家目录)、`cd -`(回上一级) | **zoxide**(智能跳转、frecency算法) |
| **pwd** | 显示当前路径 | `pwd` | 无，基础必备 |
| **mkdir** | 创建目录 | `mkdir -p dir/subdir`(递归创建) | 无，基础工具 |
| **rmdir** | 删除空目录 | `rmdir dir` | 无，配合rm使用 |
| **cp** | 复制文件 | `cp -r src/ dest/`(递归复制) | 无，配合**progress**显示进度 |
| **mv** | 移动/重命名 | `mv oldname newname` | 无，配合**progress**显示进度 |
| **rm** | 删除文件 | `rm -rf dir`(强制递归删除) | **trash-cli**(命令行回收站，防误删) |
| **touch** | 创建空文件 | `touch file.txt` | 无，基础工具 |
| **ln** | 创建链接 | `ln -s src link`(软链接) | 无，系统基础 |

### 2.2 高级文件管理
| 工具 | 功能 | 核心用法 | 备注 |
|------|------|----------|------|
| **ranger** | 终端文件管理器(预览) | `ranger` | 支持图片/代码/文档预览 |
| **lf** | 轻量终端文件管理器 | `lf` | 比ranger更快，占用更低 |
| **broot** | 目录树导航工具 | `broot` | 交互式搜索+预览，快速定位文件 |
| **clifm** | 命令行文件管理器 | `clifm` | 支持颜色、图标，ls模式显示 |

---

## 三、文本查看与编辑工具

### 3.1 查看工具
| 工具 | 功能 | 核心用法 | 现代替代 |
|------|------|----------|----------|
| **cat** | 连接显示文件 | `cat file.txt` | **bat**(语法高亮、行号、Git集成) |
| **less** | 分页查看大文件 | `less file.txt` | 无，终端标配(支持搜索/翻页) |
| **more** | 简单分页查看 | `more file.txt` | 无，基础工具 |
| **head** | 查看文件开头 | `head -n 10 file.txt` | 无，基础工具 |
| **tail** | 查看文件结尾 | `tail -f log.txt`(实时监控) | 无，日志监控必备 |
| **nl** | 显示行号 | `nl file.txt` | **bat**(自带行号显示) |

### 3.2 编辑工具
| 工具 | 功能 | 适用场景 | 备注 |
|------|------|----------|------|
| **neovim** | 现代化Vim编辑器 | 编程、配置文件编辑 | 支持LSP、插件生态丰富 |
| **vim** | 经典文本编辑器 | 系统配置、快速编辑 | 所有Linux系统默认安装 |
| **nano** | 简易编辑器 | 新手入门、快速修改 | 界面友好，无需记忆复杂命令 |
| **micro** | 现代简易编辑器 | 轻量编辑、快速修改 | 支持鼠标、语法高亮，比nano更强大 |

---

## 四、文本处理与数据过滤（开发者必备）

| 工具 | 功能 | 核心用法 | 现代替代 |
|------|------|----------|----------|
| **grep** | 文本搜索 | `grep "pattern" file.txt` | **rg**(ripgrep，速度更快、默认递归) |
| **sed** | 流编辑器 | `sed 's/old/new/g' file.txt` | 无，文本替换神器 |
| **awk** | 文本处理语言 | `awk '{print $1}' file.txt` | 无，数据提取/分析必备 |
| **cut** | 提取文本列 | `cut -d',' -f1 file.csv` | 无，CSV处理常用 |
| **sort** | 排序文本 | `sort -n numbers.txt`(数值排序) | 无，基础工具 |
| **uniq** | 去重 | `sort file.txt | uniq` | 无，配合sort使用 |
| **wc** | 统计行数/字数 | `wc -l file.txt`(行数) | 无，基础工具 |
| **paste** | 合并文件列 | `paste file1.txt file2.txt` | 无，文本合并 |
| **join** | 按关键字合并文件 | `join -t',' file1.csv file2.csv` | 无，关联数据处理 |
| **jq** | JSON解析/格式化 | `jq '.key' file.json` | 无，API开发必备 |

---

## 五、搜索与查找工具

| 工具 | 功能 | 核心用法 | 现代替代 |
|------|------|----------|----------|
| **find** | 文件查找 | `find / -name "*.log"` | **fd**(速度更快、语法更简洁) |
| **locate** | 快速文件定位 | `locate file.txt` | 无，基于数据库的快速查找 |
| **which** | 查找命令路径 | `which python` | 无，基础工具 |
| **whereis** | 查找命令/手册/源文件 | `whereis gcc` | 无，系统工具查找 |
| **fzf** | 模糊查找器 | `fzf`(交互式筛选) | 无，可集成到任何命令(文件/历史/进程) |
| **tldr** | 简化版帮助文档 | `tldr git` | 无，替代晦涩的man手册 |

---

## 六、系统监控与资源管理

### 6.1 进程管理
| 工具 | 功能 | 核心用法 | 现代替代 |
|------|------|----------|----------|
| **ps** | 查看进程 | `ps aux`(所有进程) | **procs**(彩色显示、Docker集成) |
| **top** | 系统监控 | `top` | **htop**(彩色、交互) → **btop**(更强可视化) |
| **kill** | 终止进程 | `kill -9 PID`(强制终止) | 无，基础工具 |
| **killall** | 按名称终止进程 | `killall firefox` | 无，批量终止 |
| **pkill** | 按模式终止进程 | `pkill -f "python script.py"` | 无，灵活匹配 |
| **jobs** | 查看后台任务 | `jobs` | 无，配合bg/fg使用 |
| **bg/fg** | 后台/前台任务 | `bg %1`(将任务1后台运行) | 无，任务控制 |

### 6.2 资源监控
| 工具 | 功能 | 核心用法 | 备注 |
|------|------|----------|------|
| **free** | 内存使用 | `free -h`(人类可读格式) | 无，基础监控 |
| **df** | 磁盘空间 | `df -h` | 无，基础监控 |
| **du** | 目录大小 | `du -sh dir/` | **ncdu**(交互式)、**dust**(现代化) |
| **vmstat** | 虚拟内存统计 | `vmstat 1`(每秒刷新) | 无，系统性能分析 |
| **iostat** | IO统计 | `iostat -x`(详细IO) | 无，磁盘性能分析 |
| **sar** | 系统活动报告 | `sar -u 1 10`(CPU使用率) | 无，历史数据统计 |
| **progress** | 命令进度条 | `progress`(监控cp/mv/dd等) | 无，解决无进度痛点 |
| **neofetch** | 系统信息美化 | `neofetch` | 显示系统logo、硬件信息 |

---

## 七、网络工具（运维/开发必备）

### 7.1 基础网络
| 工具 | 功能 | 核心用法 | 现代替代 |
|------|------|----------|----------|
| **ping** | 网络连通性测试 | `ping -c 4 baidu.com` | 无，基础工具 |
| **traceroute** | 路由跟踪 | `traceroute baidu.com` | **mtr**(结合ping+traceroute) |
| **curl** | 数据传输 | `curl -O url`(下载文件) | **httpie**(更友好语法) |
| **wget** | 文件下载 | `wget -c url`(断点续传) | **axel**(多线程下载) |
| **ssh** | 远程登录 | `ssh user@host` | 无，远程管理必备 |
| **scp** | 远程复制 | `scp file.txt user@host:~/` | **rsync**(更高效，支持增量) |
| **sftp** | 安全文件传输 | `sftp user@host` | 无，交互式传输 |

### 7.2 高级网络
| 工具 | 功能 | 核心用法 | 备注 |
|------|------|----------|------|
| **mtr** | 网络诊断 | `mtr baidu.com` | 实时显示路由丢包/延迟 |
| **iftop** | 带宽监控 | `iftop` | 显示各连接带宽占用 |
| **nload** | 流量可视化 | `nload` | 上传/下载速度图表 |
| **ss** | 套接字统计 | `ss -tuln`(查看监听端口) | 替代netstat，更快 |
| **ip** | 网络配置 | `ip addr`(查看IP)、`ip route`(路由) | 替代ifconfig，更强大 |
| **netstat** | 网络状态 | `netstat -tuln` | 传统工具，逐渐被ss替代 |
| **nc** | 网络调试 | `nc -l 8080`(监听端口) | 网络瑞士军刀，测试连接 |
| **dig** | DNS查询 | `dig baidu.com` | 详细DNS解析信息 |
| **nslookup** | DNS查询 | `nslookup baidu.com` | 简易DNS查询 |

---

## 八、压缩与归档工具

| 工具 | 功能 | 核心用法 | 备注 |
|------|------|----------|------|
| **tar** | 归档工具 | `tar -czvf archive.tar.gz dir/`(压缩) | 无，Linux归档标准 |
| **gzip** | GZIP压缩 | `gzip file.txt` | **pigz**(多线程压缩，更快) |
| **bzip2** | BZIP2压缩 | `bzip2 file.txt` | 比gzip压缩率更高 |
| **xz** | XZ压缩 | `xz file.txt` | 极高压缩率，适合大文件 |
| **zip/unzip** | ZIP压缩/解压 | `zip -r archive.zip dir/` | 跨平台兼容 |
| **p7zip-full** | 7-Zip工具 | `7z a archive.7z dir/` | 支持多种格式，高压缩率 |
| **unar** | 万能解压 | `unar archive.zip` | 支持几乎所有压缩格式 |

---

## 九、用户与权限管理

| 工具 | 功能 | 核心用法 | 备注 |
|------|------|----------|------|
| **useradd/userdel** | 用户管理 | `useradd -m username`(创建用户) | 系统用户管理基础 |
| **usermod** | 修改用户属性 | `usermod -aG sudo username`(添加到sudo组) | 灵活修改用户信息 |
| **passwd** | 修改密码 | `passwd username` | 系统安全基础 |
| **groupadd/groupdel** | 组管理 | `groupadd groupname` | 权限分组管理 |
| **chmod** | 修改权限 | `chmod 755 file.sh`(所有者读写执行，其他读执行) | 权限管理核心 |
| **chown** | 修改所有者 | `chown user:group file.txt` | 所有权管理 |
| **chgrp** | 修改组 | `chgrp group file.txt` | 简化组权限修改 |
| **sudo** | 提升权限 | `sudo apt update` | 安全执行管理员命令 |
| **su** | 切换用户 | `su - username` | 完整切换用户环境 |
| **id** | 查看用户信息 | `id username` | 显示UID/GID/所属组 |
| **whoami** | 显示当前用户 | `whoami` | 基础身份确认 |
| **w** | 查看登录用户 | `w` | 显示用户活动信息 |

---

## 十、磁盘与文件系统管理

| 工具 | 功能 | 核心用法 | 备注 |
|------|------|----------|------|
| **fdisk** | 磁盘分区 | `fdisk /dev/sda` | 传统分区工具 |
| **parted** | 磁盘分区 | `parted /dev/sda` | 支持GPT分区，更现代 |
| **mkfs** | 创建文件系统 | `mkfs.ext4 /dev/sda1` | 格式化分区 |
| **mount/umount** | 挂载/卸载 | `mount /dev/sda1 /mnt` | 文件系统管理核心 |
| **fsck** | 文件系统检查 | `fsck /dev/sda1` | 修复文件系统错误 |
| **blkid** | 查看块设备信息 | `blkid` | 显示UUID和文件系统类型 |
| **lsblk** | 列出块设备 | `lsblk` | 直观显示磁盘/分区结构 |
| **df** | 磁盘空间 | `df -h` | 已挂载文件系统使用情况 |
| **du** | 目录大小 | `du -sh dir/` | 目录空间占用分析 |
| **ncdu** | 交互式磁盘分析 | `ncdu /` | 快速定位大文件/目录 |

---

## 十一、软件包管理（按发行版）

### 11.1 Debian/Ubuntu系
| 工具 | 功能 | 核心用法 | 备注 |
|------|------|----------|------|
| **apt** | 包管理 | `sudo apt update && sudo apt upgrade` | 系统更新 |
| **apt-get** | 包管理(旧版) | `sudo apt-get install package` | 兼容旧系统 |
| **dpkg** | 底层包管理 | `sudo dpkg -i package.deb` | 安装本地deb包 |
| **apt-cache** | 包查询 | `apt-cache search keyword` | 搜索包 |

### 11.2 RedHat/CentOS系
| 工具 | 功能 | 核心用法 | 备注 |
|------|------|----------|------|
| **yum** | 包管理 | `sudo yum install package` | 传统工具 |
| **dnf** | 包管理(新版) | `sudo dnf install package` | 替代yum，更快 |
| **rpm** | 底层包管理 | `sudo rpm -ivh package.rpm` | 安装本地rpm包 |

### 11.3 Arch Linux系
| 工具 | 功能 | 核心用法 | 备注 |
|------|------|----------|------|
| **pacman** | 包管理 | `sudo pacman -Syu` | 系统更新+升级 |
| **yay** | AUR助手 | `yay -S package` | 安装AUR包 |

### 11.4 通用包管理
| 工具 | 功能 | 核心用法 | 备注 |
|------|------|----------|------|
| **snap** | 通用包格式 | `sudo snap install package` | 跨发行版 |
| **flatpak** | 通用包格式 | `flatpak install package` | 沙箱化应用 |

---

## 十二、终端增强与效率工具（现代必备）

| 工具 | 功能 | 核心用法 | 适用场景 |
|------|------|----------|----------|
| **zsh** | 强大shell | `zsh` | 替代bash，支持插件 |
| **oh-my-zsh** | zsh配置框架 | `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"` | 快速配置zsh |
| **starship** | 跨平台提示符 | `starship init zsh` | 显示Git/目录/权限等信息 |
| **tmux** | 终端多路复用 | `tmux new -s session` | 分屏、会话保持 |
| **screen** | 终端会话管理 | `screen -S session` | 后台挂程序，替代tmux |
| **fzf** | 模糊查找 | `fzf` | 交互式筛选文件/历史/进程 |
| **zoxide** | 智能cd | `z dir`(快速跳转) | 替代cd，学习导航习惯 |
| **atuin** | 历史记录增强 | `atuin search keyword` | 云同步历史，跨设备复用 |
| **tldr** | 简化帮助 | `tldr command` | 替代man，提供实用示例 |

---

## 十三、开发与版本控制工具

### 13.1 版本控制
| 工具 | 功能 | 核心用法 | 现代替代 |
|------|------|----------|----------|
| **git** | 版本控制 | `git clone/commit/push` | **lazygit**(交互式Git操作) |
| **gh** | GitHub CLI | `gh repo create` | 命令行管理GitHub |
| **glab** | GitLab CLI | `glab issue create` | 命令行管理GitLab |

### 13.2 开发辅助
| 工具 | 功能 | 核心用法 | 备注 |
|------|------|----------|------|
| **asdf** | 多语言版本管理 | `asdf install nodejs latest` | 替代nvm/pyenv/rvm |
| **node/npm/yarn** | JavaScript开发 | `npm install package` | 前端开发必备 |
| **python/pip** | Python开发 | `pip install package` | Python生态 |
| **go** | Go开发 | `go build` | Go语言工具链 |
| **gcc/g++** | C/C++编译 | `gcc -o program program.c` | 系统编译基础 |
| **make** | 构建工具 | `make` | 项目自动化构建 |
| **cmake** | 跨平台构建 | `cmake . && make` | 复杂项目构建 |
| **docker** | 容器化 | `docker run -it ubuntu` | 应用打包部署 |
| **lazydocker** | Docker可视化 | `lazydocker` | 交互式管理容器/镜像 |
| **kubectl** | Kubernetes管理 | `kubectl get pods` | 容器编排 |

---

## 十四、安全与加密工具

| 工具 | 功能 | 核心用法 | 备注 |
|------|------|----------|------|
| **ssh-keygen** | 生成SSH密钥 | `ssh-keygen -t ed25519` | 安全登录配置 |
| **gpg** | 加密/签名 | `gpg -c file.txt`(加密) | 数据安全保护 |
| **openssl** | 加密工具包 | `openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365` | SSL/TLS证书生成 |
| **ufw** | 防火墙管理 | `sudo ufw allow 22`(允许SSH) | 简化防火墙配置 |
| **fail2ban** | 防暴力破解 | `sudo systemctl enable fail2ban` | 保护SSH等服务 |
| **clamav** | 病毒扫描 | `clamscan -r /home` | 系统安全扫描 |

---

## 十五、其他实用工具（提升效率）

| 工具 | 功能 | 核心用法 | 适用场景 |
|------|------|----------|----------|
| **rsync** | 文件同步 | `rsync -avz src/ user@host:dest/` | 备份、远程同步 |
| **axel** | 多线程下载 | `axel -n 10 url` | 加速大文件下载 |
| **pv** | 管道查看器 | `cat file.txt | pv | gzip > file.gz` | 显示数据传输进度 |
| **htop** | 进程监控 | `htop` | 替代top，更友好 |
| **btop** | 系统监控 | `btop` | 比htop更强大的可视化 |
| **httpie** | HTTP客户端 | `http GET https://api.example.com` | 替代curl，更易读 |
| **jq** | JSON处理 | `jq '.' file.json` | API响应处理 |
| **fzf** | 模糊查找 | `cat file.txt | fzf` | 交互式筛选任何输出 |
| **tree** | 目录树显示 | `tree -L 2`(显示2层) | 可视化目录结构 |
| **watch** | 重复执行命令 | `watch -n 1 date`(每秒显示时间) | 实时监控命令输出 |

---

## 总结与使用建议

1. **基础工具优先掌握**：ls/cd/pwd/cat/grep/find/ssh等核心命令是所有操作的基础
2. **现代工具提升效率**：eza/zoxide/bat/rg/fzf等替代传统工具，大幅提升体验
3. **按场景选择**：
   - 开发：git/neovim/jq/htop/asdf/lazygit
   - 运维：tmux/rsync/iftop/mtr/ncdu/btop
   - 日常：tldr/trash-cli/starship/zsh
4. **工具组合威力大**：如`zoxide + fzf`快速导航、`bat + rg`高效搜索、`tmux + neovim`全终端开发
