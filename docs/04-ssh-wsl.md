# SSH + Tailscale：Windows 上的正确做法

先说结论：**Windows 的 cmd / PowerShell 直接跑不通。** DSH Go 连上 SSH 后执行的是 Linux 脚本（`umask`、`/proc`、`nohup`、`grep`），Windows 上没有这些，认证成功也会立刻断开。

所以 Windows 想走 SSH，要给它一个 Linux 环境。两条路：

- 装 WSL2 + Ubuntu（下面写这个）。
- 换一台 Linux 机器当主机，把 Tailscale 和 sshd 装那台上。

## 1. 装 WSL2

管理员 PowerShell：

```powershell
wsl --install -d Ubuntu
```

装完重启。重启后 Ubuntu 会让你设用户名和密码，记住。

检查：

```powershell
wsl -l -v
```

看到 Ubuntu、版本 2 就对了。

## 2. 在 Ubuntu 里装 DSH

打开 Ubuntu，执行：

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
node -v
npm i -g @deepseek-ai/dsh
dsh --version
```

`dsh --version` 能出版本号才算好。

## 3. 装 OpenSSH Server

管理员 PowerShell：

```powershell
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType Automatic
```

如果 `Add-WindowsCapability` 报 `0x800f0907`，说明系统更新源不可用。去 [Win32-OpenSSH Releases](https://github.com/PowerShell/Win32-OpenSSH/releases) 下 MSI 装，效果一样。

## 4. 让 SSH 会话进入 WSL

Windows 的 sshd 默认进 cmd。要改成 WSL。

新建一个包装脚本 `C:\ProgramData\ssh\wsl-shell.cmd`：

```bat
@echo off
wsl.exe -e /bin/bash -lc "%*"
```

管理员 PowerShell 写注册表：

```powershell
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell `
  -Value "C:\ProgramData\ssh\wsl-shell.cmd" -PropertyType String -Force
Restart-Service sshd
```

验证：在另一台机器上 `ssh 你的用户名@电脑IP`，应该直接进 Linux 提示符。

## 5. 装 Tailscale

电脑和手机都装，登同一个账号。电脑上拿 IP：

```powershell
tailscale ip -4
```

得到 `100.x.y.z`。

然后让 sshd 只监听这个地址，别把 22 端口暴露到局域网：

```powershell
$cfg = "C:\ProgramData\ssh\sshd_config"
Copy-Item $cfg "$cfg.bak"
$lines = [System.IO.File]::ReadAllLines($cfg)
$new = @("# Tailscale only", "ListenAddress 100.x.y.z") + $lines
[System.IO.File]::WriteAllLines($cfg, $new, [System.Text.Encoding]::ASCII)
Restart-Service sshd
```

把 `100.x.y.z` 换成你的地址。改完检查：

```powershell
Get-NetTCPConnection -LocalPort 22 -State Listen
```

应该只有一个 `100.x.y.z:22`。

## 6. 手机端填写

DSH Go → 切换主机 → 添加 SSH 主机：

| 字段 | 填什么 |
|---|---|
| 主机 | `100.x.y.z` |
| 用户名 | Windows 登录用户名 |
| 端口 | 22 |
| 认证 | 密码或私钥 |
| 启动命令 | `dsh web --no-open --port 0` |
| 工作目录 | `/home/你的Linux用户名` |

如果提示找不到 `dsh`，填完整路径，例如：

```
~/.nvm/versions/node/v22.20.0/bin/dsh web --no-open --port 0
```

## 7. 排错

| 现象 | 原因 | 处理 |
|---|---|---|
| 认证成功又立刻断开 | 会话还是 cmd | 检查 DefaultShell 和包装脚本 |
| `dsh: command not found` | 非交互 shell 的 PATH 没有 npm 全局目录 | 启动命令写完整路径 |
| 连不上 22 | 手机没连 Tailscale，或 sshd 没监听 | 先 `tailscale ping`，再查端口 |
| 指纹变了 | 重装或换过主机密钥 | 重新核对后再信任 |

## 一句劝

这套东西步骤多、坑也多。只是为了手机能用 DSH 的话，走 DSH Remote 就够了，十分钟能通。SSH 适合你确实需要完整功能、或者想完全自己控网络的情况。
