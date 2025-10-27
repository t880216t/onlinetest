#!/bin/bash

# 创建一个临时目录存放导出的镜像文件
temp_dir="docker_images"
mkdir -p "$temp_dir"

# 读取docker-compose.yml中的服务名称和镜像名称
services=$(docker-compose config --services)

# 导出所有镜像
for service in $services; do
    image=$(docker-compose config | awk -v service="$service" '
    $1 == service ":" {flag=1}
    flag && $1 == "image:" {print $2; exit}')
    if [ -n "$image" ]; then
        echo "导出镜像 $image 为 $service.tar"
        docker save -o "$temp_dir/$service.tar" "$image"
    fi
done

# 将所有导出的镜像文件打包为一个压缩包
tar -czvf docker_images.tar.gz -C "$temp_dir" .

# 删除临时目录
rm -rf "$temp_dir"

echo "所有镜像已导出并压缩到 docker_images.tar.gz"

