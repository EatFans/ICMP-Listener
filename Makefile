.PHONY: all clean build-darwin-amd64 build-darwin-arm64 build-windows build-linux build-darwin build-current

APP_NAME=icmp-listener
DIST_DIR=dist

# 构建所有平台（需要交叉编译工具链）
all: clean build-darwin-amd64 build-darwin-arm64 build-windows build-linux

# 仅构建 macOS 平台（推荐在 macOS 上使用）
build-darwin: clean build-darwin-amd64 build-darwin-arm64

# 构建当前平台
build-current: clean
	@echo "构建当前平台..."
	@go build -o $(DIST_DIR)/$(APP_NAME) main.go
	@echo "✓ 当前平台构建完成"

clean:
	@echo "清理 dist 目录..."
	@rm -rf $(DIST_DIR)
	@mkdir -p $(DIST_DIR)

build-darwin-amd64:
	@echo "构建 macOS (amd64)..."
	@CGO_ENABLED=1 GOOS=darwin GOARCH=amd64 go build -o $(DIST_DIR)/$(APP_NAME)-darwin-amd64 main.go
	@echo "✓ macOS (amd64) 构建完成"

build-darwin-arm64:
	@echo "构建 macOS (arm64)..."
	@CGO_ENABLED=1 GOOS=darwin GOARCH=arm64 go build -o $(DIST_DIR)/$(APP_NAME)-darwin-arm64 main.go
	@echo "✓ macOS (arm64) 构建完成"

build-windows:
	@echo "构建 Windows (amd64)..."
	@if command -v x86_64-w64-mingw32-gcc >/dev/null 2>&1; then \
		echo "使用 mingw-w64 进行交叉编译..."; \
		CGO_ENABLED=1 GOOS=windows GOARCH=amd64 CC=x86_64-w64-mingw32-gcc go build -o $(DIST_DIR)/$(APP_NAME)-windows-amd64.exe main.go && \
		echo "✓ Windows (amd64) 构建完成"; \
	elif [ "$$(uname -s)" = "MINGW64_NT" ] || [ "$$(uname -s)" = "MSYS_NT" ]; then \
		CGO_ENABLED=1 GOOS=windows GOARCH=amd64 go build -o $(DIST_DIR)/$(APP_NAME)-windows-amd64.exe main.go && \
		echo "✓ Windows (amd64) 构建完成"; \
	else \
		echo "✗ 跳过 Windows 构建（需要安装 mingw-w64）"; \
		echo "  安装命令: brew install mingw-w64"; \
	fi

build-linux:
	@echo "构建 Linux (amd64)..."
	@echo "注意：在 macOS 上交叉编译 Linux 需要 Linux 工具链，建议在 Linux 系统或 Docker 中构建"
	@if [ "$$(uname -s)" = "Linux" ]; then \
		CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -o $(DIST_DIR)/$(APP_NAME)-linux-amd64 main.go && \
		echo "✓ Linux (amd64) 构建完成"; \
	else \
		echo "✗ 跳过 Linux 构建（当前系统不是 Linux）"; \
		echo "  请在 Linux 系统上运行或使用 Docker"; \
	fi

help:
	@echo "可用命令："
	@echo "  make all              - 构建所有平台"
	@echo "  make clean            - 清理 dist 目录"
	@echo "  make build-darwin-amd64  - 仅构建 macOS (Intel)"
	@echo "  make build-darwin-arm64  - 仅构建 macOS (Apple Silicon)"
	@echo "  make build-windows    - 仅构建 Windows"
	@echo "  make build-linux      - 仅构建 Linux"
