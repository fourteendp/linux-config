aptsource() {
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
