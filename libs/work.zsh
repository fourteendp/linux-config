#!/bin/zsh
alias erpps="ps aux | grep vue-cli-service"
erpkill() {
  # 检查参数数量是否为1
  if [ $# -ne 1 ]; then
      echo "请指定端口号，用法: erpkill <端口号>"
      return 1
  fi

  local port=$1
  # 查找占用指定端口的进程PID（仅LISTEN状态）
  local pid=$(sudo lsof -i :$port -sTCP:LISTEN | grep -v "PID" | awk '{print $2}')

  if [ -z "$pid" ]; then
      echo "未找到占用端口 $port 的进程"
      return 1
  fi

  # 终止进程
  echo "正在终止端口 $port 对应的进程（PID: $pid）..."
  sudo kill -9 $pid

  # 验证是否终止成功
  local remaining_pid=$(sudo lsof -i :$port -sTCP:LISTEN | grep -v "PID" | awk '{print $2}')
  if [ -z "$remaining_pid" ]; then
      echo "端口 $port 的进程已成功终止"
  else
      echo "警告：端口 $port 的进程（PID: $remaining_pid）未能终止"
  fi
}

local ERPPATH="/mnt/d/ERP"
alias erpsvn="node $ERPPATH/.tools/main-linux.js"

function erp() {
  local project=$1
  local ip=$2
  local port=$3
  local suffix=$4

  if [ -z "$project" ]; then
    echo "请指定项目名称，用法: erp <项目名称> <IP> <端口> [后缀]"
    return 1
  fi

  if [ -z "$ip" ]; then
    echo "请指定项目名称，用法: erp <项目名称> <IP> <端口> [后缀]"
    return 1
  fi

  if [ -z "$port" ]; then
    echo "请指定项目名称，用法: erp <项目名称> <IP> <端口> [后缀]"
    return 1
  fi

  if [ -z "$suffix" ]; then
    suffix=""
  else
    suffix="/bserp"
  fi

  erpsvn cleanup $project
  erpsvn checkout $project
  local host="http://192.168.0.${ip}:${port}${suffix}"
  local frontPort="${ip}${port: -2}"
  local curip=$(ip addr | grep 'inet 192.168.0.' | awk '{print $2}' | cut -d/ -f1 | head -n 1)
  local frontHost="http://$curip:$frontPort/#/Login?companyCode=$project"

  if [ ! -f "$ERPPATH/$project/.env.dev.local" ]; then
    touch $ERPPATH/$project/.env.dev.local
  fi

  if [ ! -f "$ERPPATH/$project/.env.prod.local" ]; then
    touch $ERPPATH/$project/.env.prod.local
  fi

  echo "VUE_APP_API_URL=$host" >$ERPPATH/$project/.env.dev.local
  echo "VUE_APP_API_URL=$host" >$ERPPATH/$project/.env.prod.local

  local log="$project: $frontHost -> $host"
  echo $log
  echo "$(date '+%Y-%m-%d %H:%M:%S') $log" >>~/.erp_startup.log

  erpps

  cd $ERPPATH/$project
  volta pin node@14
  npm config set registry https://registry.npmmirror.com
  npx vue-cli-service serve --port $frontPort --mode dev
}

# 参数解析：
# 参数 1：源仓库名称（必填）
# 参数 2：起始版本（可选，默认 = 目标版本 - 1）
# 参数 3：目标版本（必填，必须为数字）
# 后续参数：需要同步补丁的其他仓库（可选）
# 核心功能：
# 自动创建补丁保存目录（$ERPPATH/.tools/patch）
# 从目标版本提取提交消息，并清理为安全的文件名格式
# 生成包含版本范围和提交消息的补丁文件（格式：仓库名_r起始版本_to_r目标版本_提交消息摘要.patch）
# 支持将生成的补丁同步应用到其他指定仓库
function erpsync() {
    # 基础参数校验
    if [ $# -lt 2 ]; then
        echo "用法: erpsync <源仓库> [起始版本] <目标版本> [其他目标仓库...]"
        return 1
    fi

    # 解析参数
    local src_repo="$1"; shift
    local target_version start_version repos=()

    for arg in "$@"; do
        if [[ "$arg" =~ ^[0-9]+$ ]]; then
            target_version="$arg"
        else
            repos+=("$arg")
        fi
    done

    [ -z "$target_version" ] && { echo "错误：未指定目标版本"; return 1; }

    # 处理起始版本（Zsh 兼容数组切片）
    if [[ "${repos[-1]}" =~ ^[0-9]+$ ]]; then
        start_version="${repos[-1]}"
        repos=("${repos[@]:0:${#repos[@]}-1}")
    else
        start_version=$((target_version - 1))
    fi

    [ $start_version -ge $target_version ] && { echo "错误：起始版本需小于目标版本"; return 1; }

    # 补丁目录准备
    local patch_dir="$ERPPATH/.tools/patch"
    mkdir -p "$patch_dir" || { echo "无法创建目录 $patch_dir"; return 1; }

    # 获取源仓库的绝对路径
    local src_repo_path="$ERPPATH/$src_repo"
    [ ! -d "$src_repo_path/.svn" ] && { echo "错误：$src_repo 不是有效的SVN工作副本"; return 1; }

    # 获取目标版本的提交消息（处理编码）
    local log_msg
    local raw_log=$(svn log -r "$target_version" "$src_repo_path" 2>/dev/null | sed -n '4p' | tr -d '\r')

    # 尝试检测和转换编码
    if echo "$raw_log" | iconv -f GBK -t UTF-8 >/dev/null 2>&1; then
        log_msg=$(echo "$raw_log" | iconv -f GBK -t UTF-8)
    else
        # 如果GBK转换失败，尝试其他编码或直接使用
        log_msg="$raw_log"
    fi

    # 确保日志消息是有效的UTF-8
    log_msg=$(echo "$log_msg" | LC_ALL=en_US.UTF-8 iconv -t UTF-8//IGNORE 2>/dev/null || echo "$log_msg")

    # 清理文件名特殊字符（更严格的清理）
    local sanitized_msg=$(echo "$log_msg" | sed -E 's/[\/\\:*?"<>|]+/_/g' | sed 's/[^a-zA-Z0-9._-]/_/g' | cut -c 1-50)
    [ -z "$sanitized_msg" ] && sanitized_msg="no_message"

    # 确保文件名是ASCII安全字符（避免UTF-8问题）
    sanitized_msg=$(echo "$sanitized_msg" | tr -cd 'a-zA-Z0-9._-')

    # 生成补丁文件名和路径（使用纯ASCII字符）
    local patch_filename="${src_repo}_r${start_version}_to_r${target_version}_${sanitized_msg}.patch"
    local patch_path="$patch_dir/$patch_filename"

    # 关键修复：进入源仓库目录，生成相对路径的补丁
    echo "生成补丁: $patch_path"

    # 设置环境变量强制UTF-8输出
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8

    (
        cd "$src_repo_path" || { echo "无法进入源仓库目录 $src_repo_path"; return 1; }

        # 生成补丁时指定输出编码为UTF-8
        svn diff -r "$start_version:$target_version" . |
        iconv -f GBK -t UTF-8//IGNORE > "$patch_path" 2>/dev/null ||
        svn diff -r "$start_version:$target_version" . > "$patch_path"
    ) || {
        echo "补丁生成失败"
        rm -f "$patch_path"
        return 1
    }

    # 检查补丁文件内容编码
    if file "$patch_path" | grep -q "UTF-8"; then
        echo "补丁文件编码：UTF-8"
    else
        echo "警告：补丁文件可能包含非UTF-8编码，尝试转换..."
        # 创建临时文件进行编码转换
        local temp_patch="${patch_path}.tmp"
        iconv -f GBK -t UTF-8//IGNORE "$patch_path" > "$temp_patch" 2>/dev/null &&
        mv "$temp_patch" "$patch_path" ||
        rm -f "$temp_patch"
    fi

    # 同步到其他仓库（预检查文件是否存在）
    if [ ${#repos[@]} -gt 0 ]; then
        echo "正在同步补丁到目标仓库..."

        for repo in "${repos[@]}"; do
            local repo_path="$ERPPATH/$repo"
            if [ -d "$repo_path/.svn" ]; then
                echo "应用到 $repo..."

                # 设置环境变量并应用补丁
                (
                    cd "$repo_path" || { echo "无法进入目标仓库目录 $repo_path"; return 1; }

                    # 确保环境使用UTF-8
                    export LC_ALL=en_US.UTF-8
                    export LANG=en_US.UTF-8

                    # 应用补丁，如果失败尝试编码转换后重试
                    if ! svn patch "$patch_path" . 2>/dev/null; then
                        echo "首次应用失败，尝试编码转换..."
                        # 创建转换后的补丁文件
                        local converted_patch="${patch_path}.converted"
                        iconv -f UTF-8 -t UTF-8//IGNORE "$patch_path" > "$converted_patch" 2>/dev/null ||
                        iconv -f GBK -t UTF-8//IGNORE "$patch_path" > "$converted_patch" 2>/dev/null

                        if [ -f "$converted_patch" ]; then
                            svn patch "$converted_patch" . 2>/dev/null &&
                            echo "转换后应用成功" ||
                            echo "警告：应用到 $repo 时发生错误"
                            rm -f "$converted_patch"
                        else
                            echo "警告：应用到 $repo 时发生错误"
                        fi
                    else
                        echo "应用成功"
                    fi
                ) || echo "警告：应用到 $repo 时发生错误"
            else
                echo "警告：$repo 不是有效的SVN工作副本，跳过"
            fi
        done
    fi

    echo "操作完成，补丁路径: $patch_path"
}

# 参数解析：
# 参数 1：patch 文件路径（必填）
# 后续参数：需要同步补丁的其他仓库（可选）, 如果只有ALL那么将同步所有仓库
# 核心功能：
# 1. 校验补丁文件的有效性
# 2. 支持指定单个/多个仓库，或使用ALL关键字同步ERPPATH下所有SVN仓库
# 3. 逐个将补丁应用到目标仓库，并输出详细执行结果
# 4. 包含完善的错误处理和日志提示
function erpsyncpatch() {
    # 基础参数校验
    if [ $# -lt 1 ]; then
        echo "用法: erpsyncpatch <补丁文件路径> [目标仓库1] [目标仓库2] ... | ALL"
        return 1
    fi

    # 解析参数
    local patch_file="$1"; shift
    local target_repos=("$@")
    local all_repos_flag=0

    # 校验补丁文件是否存在且可读
    if [ ! -f "$patch_file" ]; then
        echo "错误：补丁文件 $patch_file 不存在"
        return 1
    fi
    if [ ! -r "$patch_file" ]; then
        echo "错误：没有读取补丁文件 $patch_file 的权限"
        return 1
    fi

    # 处理 ALL 关键字（仅当第一个后续参数是ALL且无其他参数时生效）
    if [ ${#target_repos[@]} -eq 1 ] && [ "$target_repos" = "ALL" ]; then
        all_repos_flag=1
        # 清空原有仓库列表，后续自动扫描所有仓库
        target_repos=()
        echo "检测到 ALL 关键字，将同步 $ERPPATH 下所有SVN仓库"
    fi

    # 如果是ALL模式，扫描ERPPATH下所有包含.svn的目录（即SVN工作副本）
    if [ $all_repos_flag -eq 1 ]; then
        if [ -z "$ERPPATH" ]; then
            echo "错误：环境变量 ERPPATH 未设置，无法扫描所有仓库"
            return 1
        fi
        # 遍历ERPPATH下一级目录，筛选包含.svn的目录作为仓库
        for dir in "$ERPPATH"/*/; do
            if [ -d "$dir/.svn" ]; then
                # 提取仓库名称（去掉路径前缀）
                repo_name=$(basename "$dir")
                target_repos+=("$repo_name")
            fi
        done

        # 检查是否找到有效仓库
        if [ ${#target_repos[@]} -eq 0 ]; then
            echo "警告：在 $ERPPATH 下未找到任何SVN工作副本"
            return 1
        fi
        echo "已找到 ${#target_repos[@]} 个SVN仓库：${target_repos[*]}"
    fi

    # 校验目标仓库列表非空
    if [ ${#target_repos[@]} -eq 0 ] && [ $all_repos_flag -eq 0 ]; then
        echo "错误：未指定目标仓库，使用 ALL 可同步所有仓库"
        return 1
    fi

    # 逐个应用补丁到目标仓库
    local success_count=0
    local fail_count=0
    echo "开始应用补丁 $patch_file 到目标仓库..."
    for repo in "${target_repos[@]}"; do
        local repo_path="$ERPPATH/$repo"
        # 检查仓库是否为有效SVN工作副本
        if [ ! -d "$repo_path/.svn" ]; then
            echo "⚠️  跳过 $repo：不是有效的SVN工作副本（未找到 .svn 目录）"
            ((fail_count++))
            continue
        fi

        # 进入仓库目录应用补丁
        echo "🔧 正在应用补丁到 $repo ..."
        (
            cd "$repo_path" || {
                echo "❌ 应用失败：无法进入仓库目录 $repo_path"
                return 1
            }
            # 使用svn patch应用补丁，输出详细日志
            svn patch "$patch_file" . 2>&1
            if [ $? -eq 0 ]; then
                echo "✅ $repo 补丁应用成功"
                return 0
            else
                echo "❌ $repo 补丁应用失败（可能存在文件不匹配/冲突）"
                return 1
            fi
        )
        # 统计成功/失败数量
        if [ $? -eq 0 ]; then
            ((success_count++))
        else
            ((fail_count++))
        fi
    done

    # 输出最终执行结果
    echo -e "\n===== 执行结果汇总 ====="
    echo "补丁文件：$patch_file"
    echo "成功应用：$success_count 个仓库"
    echo "应用失败：$fail_count 个仓库"
    if [ $fail_count -eq 0 ]; then
        echo "🎉 所有仓库补丁应用完成！"
        return 0
    else
        echo "⚠️  部分仓库应用失败，请检查日志详情"
        return 1
    fi
}
