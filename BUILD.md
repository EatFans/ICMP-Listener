# 跨平台打包说明

本项目支持跨平台打包，可以为 macOS、Windows 和 Linux 生成可执行文件。

## 支持的平台

- **macOS (Intel)**: `icmp-listener-darwin-amd64`
- **macOS (Apple Silicon)**: `icmp-listener-darwin-arm64`
- **Windows**: `icmp-listener-windows-amd64.exe`
- **Linux**: `icmp-listener-linux-amd64`

## 打包方法

### 方法一：使用 Makefile（推荐）

```bash
# 构建所有平台（需要交叉编译工具链）
make all

# 仅构建 macOS 平台（推荐在 macOS 上使用）
make build-darwin

# 构建当前平台
make build-current

# 仅构建特定平台
make build-darwin-amd64   # macOS Intel
make build-darwin-arm64   # macOS Apple Silicon
make build-windows        # Windows（需要 mingw-w64）
make build-linux          # Linux

# 清理 dist 目录
make clean

# 查看帮助
make help
```

### 方法二：使用 Shell 脚本（智能检测）

```bash
# 执行打包脚本（自动检测可用的编译工具链）
./build.sh
```

脚本会自动检测系统环境，尝试构建所有平台，并报告成功和失败的情况。

## 输出目录

所有打包好的可执行文件将统一放在 `dist/` 目录中。

## 交叉编译要求

由于本项目使用了 `gopacket/pcap` 库，该库依赖 C 语言的 libpcap，因此需要启用 CGO 进行编译。

### 在 macOS 上编译

1. **macOS 平台**：可以直接编译 Intel 和 Apple Silicon 版本
   ```bash
   make build-darwin
   ```

3. **Windows 平台**：需要安装 mingw-w64
   ```bash
   brew install mingw-w64
   make build-windows
   ```

### 在 Linux 上编译

1. **Linux 平台**：可以直接编译
   ```bash
   make build-linux
   ```

2. **Windows 平台**：需要安装 mingw-w64
   ```bash
   sudo apt-get install mingw-w64  # Debian/Ubuntu
   make build-windows
   ```

### 在 Windows 上编译

建议使用 WSL 或在对应平台上直接编译。

## 推荐方案

为了获得最佳兼容性和避免交叉编译问题，建议：

### 方案一：在各自平台上构建

1. **在 macOS 上**：构建两个 macOS 版本
   ```bash
   make build-darwin
   ```

2. **在 Linux 上**：构建 Linux 版本
   ```bash
   make build-linux
   ```

3. **在 Windows 上**：构建 Windows 版本
   ```bash
   go build -o dist/icmp-listener-windows-amd64.exe main.go
   ```

### 方案二：在 macOS 上使用 Docker 构建 Linux 版本

如果你在 macOS 上需要构建 Linux 版本：

```bash
# 使用 Docker 构建脚本
./build-docker.sh
```

这会在 Docker 容器中编译 Linux 版本，避免交叉编译问题。

### 方案三：使用 GitHub Actions（推荐）

项目已配置 GitHub Actions 工作流，推送代码到 GitHub 后会自动在各平台上构建：

- 推送到 `main` 或 `master` 分支：触发构建
- 创建 `v*` 标签：自动创建 Release 并上传所有平台的可执行文件

```bash
# 创建并推送标签
git tag v1.0.0
git push origin v1.0.0
```

## 运行注意事项

1. **权限要求**：在 Linux 和 macOS 上运行此程序需要 root 权限（因为需要访问网络接口）
   ```bash
   sudo ./icmp-listener-darwin-arm64
   ```

2. **依赖要求**：
   - **macOS**：系统自带 libpcap，无需额外安装
   - **Linux**：大多数发行版默认已安装 libpcap，如未安装：
     ```bash
     sudo apt-get install libpcap-dev  # Debian/Ubuntu
     sudo yum install libpcap-devel    # CentOS/RHEL
     ```
   - **Windows**：需要安装 [Npcap](https://npcap.com/) 或 WinPcap

3. **防火墙**：确保防火墙允许 ICMP 流量通过
