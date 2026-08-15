<#
.SYNOPSIS
  一键配置 Codex 接入 DeepSeek 并安装 ChatGPT 桌面端（Windows 10）

.DESCRIPTION
  流程：确保 winget（Win10 未内置，自动安装或引导商店）
        -> 创建 ~/.codex -> 运行 DeepSeek 配置脚本
        -> 自动安装 ChatGPT 桌面端（Microsoft Store）

.USAGE
  推荐（远程一键，配合 jsDelivr/GitHub）：
      Set-ExecutionPolicy Bypass -Scope Process -Force; irm https://cdn.jsdelivr.net/gh/DM-beginner/xianyu-deepseek-setup-lite@main/install-win10.ps1 -OutFile $env:TEMP\xs.ps1; & $env:TEMP\xs.ps1

  本地运行：
      powershell -ExecutionPolicy Bypass -File .\install-win10.ps1

.NOTES
  - 配置环节无需 VPN（DeepSeek 为国内服务，直连）。
  - ChatGPT 桌面端经 Microsoft Store 安装；国内部分网络可能下不到，
    失败时脚本会给出手动安装指引。
  - 首次打开 ChatGPT 桌面端需登录 OpenAI 账号（免费，登录需科学上网）。
  - 脚本最后会弹出 DeepSeek 配置菜单，需要客户手动：
      输入 1 = deepseek-v4-flash（更便宜、更快）
      输入 2 = deepseek-v4-pro（更强）
      再粘贴 DeepSeek API Key（sk- 开头，在 https://platform.deepseek.com/api_keys 获取）
#>

$ErrorActionPreference = 'Stop'

# 控制台输出 UTF-8，避免中文乱码（配合脚本 UTF-8 BOM + -OutFile 字节下载执行）
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}
$OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Step { param([string]$m) Write-Host ""; Write-Host "=== $m ===" -ForegroundColor Cyan }
function Write-Ok   { param([string]$m) Write-Host "[OK] $m" -ForegroundColor Green }
function Write-Warn { param([string]$m) Write-Host "[!] $m" -ForegroundColor Yellow }

# 刷新当前会话的 PATH，让刚装好的 winget 立即可用
function Update-SessionPath {
    $machine = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user    = [System.Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machine;$user"
}

Write-Step "检查 winget"
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Warn "Win10 默认不带 winget，尝试自动安装 App Installer ..."
    $ProgressPreference = 'SilentlyContinue'
    $tmp = Join-Path $env:TEMP "winget-bootstrap"
    New-Item -ItemType Directory -Force -Path $tmp | Out-Null
    try {
        # 依赖：VCLibs
        $vclibs = Join-Path $tmp "vclibs.appx"
        Invoke-WebRequest "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -OutFile $vclibs
        Add-AppxPackage -Path $vclibs -ErrorAction SilentlyContinue
        # App Installer（winget 本体）
        $installer = Join-Path $tmp "winget.msixbundle"
        Invoke-WebRequest "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -OutFile $installer
        Add-AppxPackage -Path $installer
        Update-SessionPath
    } catch {
        Write-Warn "自动安装失败：$($_.Exception.Message)"
    }
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Ok "winget 安装成功"
    } else {
        Write-Warn "自动安装失败（多为网络原因）。请打开 Microsoft Store 搜索『应用安装程序』安装后重跑本脚本。"
        Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1"
        throw "winget 不可用，已打开应用商店。"
    }
}
Write-Ok "winget 可用"

Write-Step "准备 Codex 配置目录 (~/.codex)"
$codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }
New-Item -ItemType Directory -Force -Path $codexHome | Out-Null
Write-Ok "配置目录就绪: $codexHome"

Write-Step "运行 DeepSeek 一键配置脚本"
Write-Host ""
Write-Host "接下来会弹出菜单，请让客户操作：" -ForegroundColor White
Write-Host "  输入 1 = 使用 deepseek-v4-flash（更便宜、更快）"
Write-Host "  输入 2 = 使用 deepseek-v4-pro（最强）"
Write-Host "  然后粘贴 DeepSeek API Key（sk- 开头）"
Write-Host "  API Key 获取地址：https://platform.deepseek.com/api_keys"
Write-Host ""
irm https://cdn.deepseek.com/api-docs/codex-deepseek-setup-en.ps1 | iex

Write-Step "安装 ChatGPT 桌面端"
$chatgptInstalled = $false
if (Get-AppxPackage -Name "*ChatGPT*" -ErrorAction SilentlyContinue) { $chatgptInstalled = $true }
if (Test-Path "$env:LOCALAPPDATA\Programs\ChatGPT\ChatGPT.exe") { $chatgptInstalled = $true }
if ($chatgptInstalled) {
    Write-Ok "ChatGPT 桌面端已安装"
} else {
    # Microsoft Store（winget）单通道安装
    Write-Host "尝试 Microsoft Store 安装（winget）..."
    winget install --id 9NT1R1C2HH7J --source msstore --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "ChatGPT 桌面端安装完成"
    } else {
        # 仅商店通道：失败只给手动指引，不做第三方 CDN 直链
        Write-Warn "商店安装失败（退出码 $LASTEXITCODE，国内网络常见）。"
        Write-Warn "请手动安装：打开 Microsoft Store 搜索『ChatGPT』并点击安装，"
        Write-Warn "或稍后重跑本脚本（商店通道可能只是临时网络波动）。"
        Write-Warn "不想装桌面端也可改用 VS Code Codex 插件（见文末提示）。"
    }
}

Write-Step "完成"
Write-Host "配置与安装已完成。使用方式："
Write-Host "  打开 ChatGPT 桌面端（需登录 OpenAI 账号，免费，登录需科学上网），"
Write-Host "  右下角/底部模型名显示 deepseek-v4-flash 或 deepseek-v4-pro 即成功。"
Write-Host "  备选：VS Code 扩展市场搜 Codex 安装（无需科学上网）。"
