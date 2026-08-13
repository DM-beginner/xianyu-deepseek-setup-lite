<#
.SYNOPSIS
  一键配置 Codex 接入 DeepSeek 并安装 ChatGPT 桌面端（Windows 11）

.DESCRIPTION
  流程：确保 winget -> 创建 ~/.codex -> 运行 DeepSeek 配置脚本
        -> 自动安装 ChatGPT 桌面端（Microsoft Store）

.USAGE
  推荐（远程一键，配合 jsDelivr/GitHub）：
      Set-ExecutionPolicy Bypass -Scope Process -Force; irm https://cdn.jsdelivr.net/gh/DM-beginner/xianyu-deepseek-setup-lite@main/install-win11.ps1 -OutFile $env:TEMP\xs.ps1; & $env:TEMP\xs.ps1

  本地运行：
      powershell -ExecutionPolicy Bypass -File .\install-win11.ps1

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

Write-Step "检查 winget"
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Warn "未找到 winget。Win11 一般已内置；若缺失，请打开 Microsoft Store 安装『应用安装程序』后重跑本脚本。"
    Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1"
    throw "winget 不可用，已打开应用商店。安装完成后请重新运行本脚本。"
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

Write-Step "安装 ChatGPT 桌面端（Microsoft Store）"
$chatgptInstalled = $false
if (Get-AppxPackage -Name "*ChatGPT*" -ErrorAction SilentlyContinue) { $chatgptInstalled = $true }
if (Test-Path "$env:LOCALAPPDATA\Programs\ChatGPT\ChatGPT.exe") { $chatgptInstalled = $true }
if ($chatgptInstalled) {
    Write-Ok "ChatGPT 桌面端已安装"
} else {
    Write-Host "正在从 Microsoft Store 安装 ChatGPT（静默安装，不显示进度，请保持网络，需几分钟）..."
    winget install --id 9NT1R1C2HH7J --source msstore --accept-package-agreements --accept-source-agreements --silent
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "ChatGPT 桌面端安装完成"
    } else {
        Write-Warn "首次安装失败（退出码 $LASTEXITCODE）。常见原因：ChatGPT 仅在美国区商店上架，中国区商店搜不到此应用。"
        Write-Host "正在把商店区域切换为美国后重试（下载仍走微软 CDN，国内可达）..."
        try {
            New-Item -Path "HKCU:\Control Panel\International\Geo" -Force | Out-Null
            Set-ItemProperty -Path "HKCU:\Control Panel\International\Geo" -Name Nation -Value 244 -Type DWord
            Get-Process -Name WinStore -ErrorAction SilentlyContinue | Stop-Process -Force
            Get-Process -Name WinStore.App -ErrorAction SilentlyContinue | Stop-Process -Force
            Start-Sleep 3
            # 刷新 msstore 源缓存（区域切换后旧缓存仍按中国区目录查询，会继续报"找不到包"）
            winget source update msstore 2>$null | Out-Null
            winget install --id 9NT1R1C2HH7J --source msstore --accept-package-agreements --accept-source-agreements --silent
            if ($LASTEXITCODE -eq 0) {
                Write-Ok "ChatGPT 桌面端安装完成（已切换商店区域为美国）"
            } else {
                Write-Warn "切换区域后仍失败（退出码 $LASTEXITCODE）"
                throw "ChatGPT 安装失败"
            }
        } catch {
            Write-Warn "自动安装失败：$($_.Exception.Message)"
            Write-Warn "请手动安装（二选一）："
            Write-Warn "  1. Microsoft Store 搜索 ChatGPT（本机将自动打开商店页面，区域已切换美国）"
            Write-Warn "  2. 浏览器打开 https://chatgpt.com/download 下载安装（需科学上网）"
            Start-Process "ms-windows-store://pdp/?ProductId=9NT1R1C2HH7J"
        }
    }
}

Write-Step "完成"
Write-Host "配置与安装已完成。使用方式："
Write-Host "  打开 ChatGPT 桌面端（需登录 OpenAI 账号，免费，登录需科学上网），"
Write-Host "  右下角/底部模型名显示 deepseek-v4-flash 或 deepseek-v4-pro 即成功。"
Write-Host "  备选：VS Code 扩展市场搜 Codex 安装（无需科学上网）。"
