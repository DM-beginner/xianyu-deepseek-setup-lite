# 闲鱼 · DeepSeek + Codex 一键配置包（商家自用版 · 无激活码）

> **本仓库 = 商家自用版**：无激活码校验，供你远控客户电脑时自己跑命令一键安装。
> 客户自助版（含激活码+机器绑定防传播）在 `github.com/DM-beginner/xianyu-deepseek-setup`。

给客户电脑一键配置 Codex 接入 DeepSeek 模型，并**自动安装 ChatGPT 桌面端**。支持 Windows 10 / Windows 11 / macOS 三套系统。

> 核心结论先行：
> 1. **配置环节全程不需要 VPN**（DeepSeek 是国内服务，直连）。
> 2. 脚本自动完成三件事：创建 `~/.codex` → 运行 DeepSeek 官方配置脚本 → **自动安装 ChatGPT 桌面端**。无需装 Node.js / Codex CLI。
> 3. **脚本已永久托管在 GitHub**：`github.com/DM-beginner/xianyu-deepseek-setup-lite`，jsDelivr CDN 链接下载（国内直连），不依赖你本机在线。
> 4. 唯一需要科学上网的环节：**ChatGPT 桌面端首次打开要登录 OpenAI 账号**（免费注册）。不想碰 VPN 就用 VS Code Codex 插件（无需登录步骤，见文末）。
> 5. **注意**：本仓库公开且无激活码防护，请勿把本仓库链接发给客户；客户一律走激活码版仓库。

---

## 文件清单

| 文件 | 适用系统 | 脚本做的事 |
| --- | --- | --- |
| `install-win11.ps1` | Windows 11 | 创建 ~/.codex → DeepSeek 配置 → winget 装 ChatGPT 桌面端 |
| `install-win10.ps1` | Windows 10 | 同上（多一步：先装 winget） |
| `install-mac.sh` | macOS | 同上（brew 装 ChatGPT） |

---

## 客户操作步骤（Windows 11）

在 **PowerShell** 里执行（右键开始菜单 → 终端 / PowerShell）：

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; irm https://cdn.jsdelivr.net/gh/DM-beginner/xianyu-deepseek-setup-lite@main/install-win11.ps1 | iex
```

## 客户操作步骤（Windows 10）

同样在 PowerShell 里：

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; irm https://cdn.jsdelivr.net/gh/DM-beginner/xianyu-deepseek-setup-lite@main/install-win10.ps1 | iex
```

## 客户操作步骤（macOS）

在「终端」里执行：

```bash
bash <(curl -fsSL https://cdn.jsdelivr.net/gh/DM-beginner/xianyu-deepseek-setup-lite@main/install-mac.sh)
```

> 备选地址（jsDelivr 失效时）：把 `cdn.jsdelivr.net/gh/...` 换成 `raw.githubusercontent.com/DM-beginner/xianyu-deepseek-setup-lite/main/...`（GitHub 直链，国内部分网络访问慢）。

### 脚本做了什么

1. 创建 `~/.codex` 目录（DeepSeek 官方脚本的唯一前提，其余文件由它自动生成）；
2. 运行 DeepSeek 官方配置脚本（交互：选模型 + 贴 API Key）；
3. 自动安装 ChatGPT 桌面端：
   - Windows：`winget install --id 9NT1R1C2HH7J --source msstore`（Microsoft Store 官方应用）；
   - macOS：用 Homebrew 安装（未装 brew 时脚本会给出 Homebrew 安装指引，或提示手动下载）。

不需要管理员权限。

### 最后一步（三个系统通用）

脚本运行 DeepSeek 配置脚本时，**客户需要手动**：

1. 输入 `1`（deepseek-v4-flash，便宜快速）或 `2`（deepseek-v4-pro，最强）；
2. 粘贴 DeepSeek API Key（`sk-` 开头）。

API Key 获取：客户自行注册 [DeepSeek 开放平台](https://platform.deepseek.com/api_keys) → 创建 API Key → 充值即可。

---

## 装完后客户怎么用

- **ChatGPT 桌面端**（脚本已自动安装）：首次打开需**登录 OpenAI 账号**（免费注册，登录需科学上网），登录后右下角/底部模型名显示 `deepseek-v4-flash` 或 `deepseek-v4-pro` 即成功；
- **VS Code Codex 插件**（备选，**无需登录、无需科学上网**）：扩展市场搜 `Codex` 安装，装好输入框旁显示 DeepSeek 模型名即成功。

两者共用 `~/.codex` 配置，DeepSeek 配一次两端通用。

---

## 是否需要 VPN（完整说明）

| 环节 | 需要 VPN？ | 原因 |
| --- | --- | --- |
| 下载脚本（jsDelivr CDN） | 否 | 国内直连 |
| DeepSeek 配置脚本（cdn.deepseek.com） | 否 | 国内 CDN，直连 |
| DeepSeek API（api.deepseek.com） | 否 | 国内公司，直连 |
| 用 API Key 跑 DeepSeek 模型 | 否 | 配置里 `preferred_auth_method=apikey`，绕开 OpenAI 登录 |
| Windows 装 ChatGPT（Microsoft Store） | 否 | 商店国内可用（个别区域/网络可能下不到，失败有手动指引） |
| mac 装 ChatGPT（brew → 官方 CDN） | 否（但慢） | 下载源 persistent.oaistatic.com 国内可达但约 80KB/s，487MB 需 1-2 小时（有断点续传） |
| VS Code 装 Codex 插件 | 否 | 扩展市场国内可访问 |
| **ChatGPT 桌面端首次登录 OpenAI 账号** | **需要** | openai.com / chatgpt.com 国内受限 |
| **登录 OpenAI 账号用 GPT 模型** | **需要** | openai.com / chatgpt.com 国内受限 |

**一句话**：配置 + 安装环节不需要 VPN；只有「ChatGPT 桌面端登录 OpenAI 账号」需要。客户完全不想碰 VPN → 用 VS Code Codex 插件。

---

## 本机托管备选（ngrok / Cloudflare Tunnel）

> 脚本已永久托管在 GitHub（jsDelivr CDN，国内直连），**正常情况下不需要**下面这些方案。仅在你想用「自己域名」或「本机临时托管」时才需要。

### ngrok 远控方案

你自己电脑托管脚本，用 ngrok 暴露成公网域名，远控客户电脑时让客户直接一条命令下载运行。

1. 起静态文件服务器（8080 端口）：
   ```bash
   cd ~/Downloads/xianyu-deepseek-setup-lite && python3 -m http.server 8080
   ```
2. 开 ngrok：`ngrok http 8080`，得到 `https://xxxx.ngrok-free.app`。
3. 客户命令：`irm https://xxxx.ngrok-free.app/install-win11.ps1 | iex`。

注意事项：
- **免费版 ngrok**：域名每次重启会变、有访问确认页（浏览器/irm 可能被拦截）、有连接数限制；同一账号同时只允许 1 个在线隧道。
- 仅适合测试/应急，做生意建议 GitHub 托管或 Cloudflare 命名隧道。

### Cloudflare Tunnel 方案（免费，无确认页）

原理：`cloudflared` 主动向外连 Cloudflare 边缘，公网请求经边缘转发到你电脑的 `localhost:8080`。不需要公网 IP、不需要端口转发。

安装：

```bash
# macOS
brew install cloudflared
# Windows（PowerShell）
winget install -e --id Cloudflare.cloudflared
```

**快速隧道（0 配置，临时用）**：

```bash
cloudflared tunnel --url http://localhost:8080
```

终端输出里找 `https://xxxx.trycloudflare.com`。**无确认页**（PowerShell 的 `irm` 可直接下载脚本，已验证），但域名随机、进程停了就失效。

**命名隧道（固定域名，适合长期）**：

前提：一个你自己的域名，DNS 托管到 Cloudflare（改 NS，一次性）。

```bash
cloudflared tunnel login                          # 浏览器登录授权，选你的域名
cloudflared tunnel create deepseek-cdn            # 创建命名隧道，记下 UUID
# 写配置 ~/.cloudflared/config.yml：
#   url: http://localhost:8080
#   tunnel: <UUID>
#   credentials-file: ~/.cloudflared/<UUID>.json
cloudflared tunnel route dns deepseek-cdn cdn.你的域名.com   # 绑定域名
cloudflared tunnel run deepseek-cdn                          # 运行
```

之后 `https://cdn.你的域名.com/install-win11.ps1` 永久可用。

---

## 客户电脑操作步骤（商家版，完整流程）

### 1. 准备工作

- 客户确认系统：Windows 10 / 11 或 macOS；
- 远控工具连上客户电脑（ToDesk / AnyDesk / RustDesk / 向日葵）；
- 客户要有 DeepSeek API Key（https://platform.deepseek.com/api_keys），或你用自己的 Key 代配（注意：Key 写进客户 `~/.codex/config.toml`，客户能看到）。

### 2. Windows 客户执行

按 `Win+X` → 选择「终端」或「Windows PowerShell」，粘贴（Win11 / Win10 对应一个）：

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; irm https://cdn.jsdelivr.net/gh/DM-beginner/xianyu-deepseek-setup-lite@main/install-win11.ps1 | iex
```

脚本自动：创建 `~/.codex` → 弹出 DeepSeek 菜单 → 装 ChatGPT 桌面端。菜单出现时（你或客户）：

1. 输入 `1`（flash，便宜）或 `2`（pro，更强）；
2. 粘贴 API Key（`sk-` 开头）。

### 3. macOS 客户执行

打开「终端」，粘贴：

```bash
bash <(curl -fsSL https://cdn.jsdelivr.net/gh/DM-beginner/xianyu-deepseek-setup-lite@main/install-mac.sh)
```

同样选模型 + 贴 API Key。

### 4. 登录 ChatGPT（需科学上网）

- 脚本装完 ChatGPT 桌面端后，**首次打开需要登录 OpenAI 账号**（免费注册）。这一步客户网络需科学上网，或你自己处理；
- 客户没有科学上网条件 → 改用 VS Code Codex 插件（无需登录）：VS Code → 扩展 → 搜 `Codex` → 安装。

### 5. 验收

- 打开 ChatGPT 桌面端，右下角/底部模型名显示 `deepseek-v4-flash/pro` 即成功；
- 或让客户在 Codex 里问一句中文，确认正常回答且显示 DeepSeek 模型名。

---

## 常见问题

- **脚本需要管理员权限吗？** 不需要。只创建用户目录 `~/.codex`、跑配置脚本、winget 装应用。
- **ChatGPT 桌面端装不上？** Windows 走 Microsoft Store，个别网络/区域可能下不到——脚本会打开商店页面或提示从 https://chatgpt.com/download 手动装（需科学上网）；mac 走 brew（下载源国内较慢约 1-2 小时，耐心等或手动下载）。
- **客户没有科学上网，能用吗？** 能——改用 VS Code Codex 插件（无需登录 OpenAI 账号），模型照用 DeepSeek。
- **配置后 codex 仍显示 fallback/unknown model？** 说明 `models.json` 没被加载，重跑一次 DeepSeek 配置脚本即可（脚本支持重跑，会自动识别已装状态）。
- **想换模型或还原？** 重跑 DeepSeek 配置脚本，菜单选 `1`/`2` 切换 flash/pro，选 `3` 还原默认配置。
- **jsDelivr 链接打不开？** 换 GitHub raw 直链（见上文备选地址），或等几秒重试（CDN 首次拉取需几秒）。
