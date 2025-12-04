#!/bin/bash

# 使用 Docker 构建 Linux 版本（Debian 基础镜像）

APP_NAME="icmp-listener"
DIST_DIR="dist"

echo "======================================"
echo "  使用 Docker 构建 Linux 版本"
echo "  (Debian 基础镜像)"
echo "======================================"

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "错误: 未找到 Docker，请先安装 Docker"
    echo "访问 https://www.docker.com/get-started 下载安装"
    exit 1
fi

# 创建 dist 目录
mkdir -p "$DIST_DIR"

echo ""
echo "开始构建..."

# 构建 Docker 镜像并运行
docker build -f Dockerfile.build.debian -t icmp-listener-builder-debian .

if [ $? -eq 0 ]; then
    echo ""
    echo "从容器中复制构建产物..."
    
    # 创建临时容器
    CONTAINER_ID=$(docker create icmp-listener-builder-debian)
    
    # 复制文件
    docker cp "$CONTAINER_ID:/build/dist/${APP_NAME}-linux-amd64" "$DIST_DIR/"
    
    # 删除临时容器
    docker rm "$CONTAINER_ID" > /dev/null
    
    echo ""
    echo "======================================"
    echo "  构建完成！"
    echo "======================================"
    echo ""
    ls -lh "$DIST_DIR/${APP_NAME}-linux-amd64"
    echo ""
    echo "Linux 可执行文件已保存到 $DIST_DIR 目录"
else
    echo ""
    echo "构建失败"
    echo "请查看 DOCKER_TROUBLESHOOTING.md 获取帮助"
    exit 1
fi
