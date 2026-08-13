#!/usr/bin/env bash
#
# 一键配置 Codex 接入 DeepSeek 并安装 ChatGPT 桌面端（macOS）
#
# 流程：创建 ~/.codex -> 运行 DeepSeek 配置脚本 -> 用 Homebrew 安装 ChatGPT
#
# 用法：
#   推荐（远程一键，配合 jsDelivr/GitHub）：
#     bash <(curl -fsSL https://cdn.jsdelivr.net/gh/DM-beginner/xianyu-deepseek-setup@main/install-mac.sh)
#
#   本地运行：
#     chmod +x install-mac.sh && ./install-mac.sh
#
# 说明：
#   - 配置环节无需 VPN（DeepSeek 为国内服务，直连）。
#   - ChatGPT 用 Homebrew 安装；未装 brew 时脚本给出安装指引或手动下载提示。
#   - brew 下载源为官方 CDN（约 487MB），国内网络可能较慢（1-2 小时），有断点续传。
#   - 首次打开 ChatGPT 桌面端需登录 OpenAI 账号（免费，登录需科学上网）。
#   - 脚本最后会弹出 DeepSeek 配置菜单，需要客户手动：
#       输入 1 = deepseek-v4-flash（更便宜、更快）
#       输入 2 = deepseek-v4-pro（更强）
#       再粘贴 DeepSeek API Key（sk- 开头，在 https://platform.deepseek.com/api_keys 获取）

set -euo pipefail

step() { printf '\n=== %s ===\n' "$1"; }
ok()   { printf '[OK] %s\n' "$1"; }
warn() { printf '[!] %s\n' "$1" >&2; }

step "准备 Codex 配置目录 (~/.codex)"
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
mkdir -p "$CODEX_HOME_DIR"
ok "配置目录就绪: $CODEX_HOME_DIR"

step "运行 DeepSeek 一键配置脚本"
echo ""
echo "接下来会弹出菜单，请让客户操作："
echo "  输入 1 = 使用 deepseek-v4-flash（更便宜、更快）"
echo "  输入 2 = 使用 deepseek-v4-pro（最强）"
echo "  然后粘贴 DeepSeek API Key（sk- 开头）"
echo "  API Key 获取地址：https://platform.deepseek.com/api_keys"
echo ""
bash <(curl -fsSL https://cdn.deepseek.com/api-docs/codex-deepseek-setup.sh)

install_chatgpt() {
    if [ -d "/Applications/ChatGPT.app" ]; then
        ok "ChatGPT 桌面端已安装"
        return 0
    fi
    if ! command -v brew >/dev/null 2>&1; then
        warn "未检测到 Homebrew，无法自动安装 ChatGPT。请先安装 Homebrew："
        echo ""
        echo "  官方安装："
        echo '    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        echo "  清华镜像（国内更快）："
        echo '    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"'
        echo '    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"'
        echo '    /bin/bash -c "$(curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git/raw/HEAD/install.sh)"'
        echo ""
        echo "  或手动下载安装 ChatGPT：浏览器打开 https://chatgpt.com/download（需科学上网）"
        echo ""
        echo "  装好 brew 后重跑本脚本即可自动完成后续安装。"
        return 1
    fi
    echo "正在用 Homebrew 安装 ChatGPT（文件约 487MB，国内网络可能需 1-2 小时，中断重跑会断点续传）..."
    brew install --cask chatgpt
}

step "安装 ChatGPT 桌面端"
if install_chatgpt; then
    ok "ChatGPT 桌面端安装完成"
else
    warn "ChatGPT 桌面端未能自动安装，请按上面提示处理后再重跑本脚本。"
fi

step "完成"
echo "配置与安装已完成。使用方式："
echo "  打开 ChatGPT 桌面端（需登录 OpenAI 账号，免费，登录需科学上网），"
echo "  右下角/底部模型名显示 deepseek-v4-flash 或 deepseek-v4-pro 即成功。"
echo "  备选：VS Code 扩展市场搜 Codex 安装（无需科学上网）。"
