#!/bin/bash

# 跨平台打包脚本
# 支持 macOS (amd64/arm64)、Windows、Linux

APP_NAME="icmp-listener"
DIST_DIR="dist"
SUCCESS_COUNT=0
FAIL_COUNT=0

echo "======================================"
echo "  ICMP-Listener 跨平台打包工具"
echo "======================================"

# 清理并创建 dist 目录
echo ""
echo "清理 dist 目录..."
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

# 检测操作系统
OS_TYPE=$(uname -s)
echo "检测到操作系统: $OS_TYPE"

# 构建函数
build_target() {
    local goos=$1
    local goarch=$2
    local output=$3
    local description=$4
    
    echo ""
    echo "构建 $description..."
    
    if CGO_ENABLED=1 GOOS=$goos GOARCH=$goarch go build -o "$output" main.go 2>/dev/null; then
        echo "✓ $description 构建完成"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        return 0
    else
        echo "✗ $description 构建失败（可能缺少交叉编译工具链）"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi
}

# 构建 macOS (Intel)
build_target "darwin" "amd64" "$DIST_DIR/${APP_NAME}-darwin-amd64" "macOS (amd64 - Intel)"

# 构建 macOS (Apple Silicon)
build_target "darwin" "arm64" "$DIST_DIR/${APP_NAME}-darwin-arm64" "macOS (arm64 - Apple Silicon)"

# 构建 Linux
build_target "linux" "amd64" "$DIST_DIR/${APP_NAME}-linux-amd64" "Linux (amd64)"

# 构建 Windows（需要 mingw-w64）
echo ""
echo "构建 Windows (amd64)..."
if command -v x86_64-w64-mingw32-gcc &> /dev/null; then
    if CGO_ENABLED=1 GOOS=windows GOARCH=amd64 CC=x86_64-w64-mingw32-gcc go build -o "$DIST_DIR/${APP_NAME}-windows-amd64.exe" main.go 2>/dev/null; then
        echo "✓ Windows (amd64) 构建完成"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo "✗ Windows (amd64) 构建失败"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
else
    echo "✗ Windows (amd64) 跳过（需要安装 mingw-w64: brew install mingw-w64）"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# 显示构建结果
echo ""
echo "======================================"
echo "  构建完成！"
echo "======================================"
echo ""
echo "成功: $SUCCESS_COUNT 个平台"
echo "失败/跳过: $FAIL_COUNT 个平台"
echo ""

if [ $SUCCESS_COUNT -gt 0 ]; then
    echo "生成的文件："
    ls -lh "$DIST_DIR"
    echo ""
    echo "可执行文件已保存到 $DIST_DIR 目录"
fi

if [ $FAIL_COUNT -gt 0 ]; then
    echo ""
    echo "提示："
    echo "- Windows 交叉编译需要: brew install mingw-w64"
    echo "- Linux 交叉编译在 macOS 上可能需要额外配置"
    echo "- 建议在对应平台上进行本地编译以获得最佳兼容性"
fi
