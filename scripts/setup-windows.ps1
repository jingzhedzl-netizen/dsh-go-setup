# 可选安装：Remote 插件、OpenSSH、Tailscale
# 默认什么都不做，必须显式加开关
# 用法：
#   powershell -ExecutionPolicy Bypass -File .\scripts\setup-windows.ps1 -RemotePlugin
#   powershell -ExecutionPolicy Bypass -File .\scripts\setup-windows.ps1 -OpenSSH -Tailscale

param(
    [switch]$RemotePlugin,
    [switch]$OpenSSH,
    [switch]$Tailscale
)

$ErrorActionPreference = "Stop"

function NeedAdmin {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) { throw "这一步需要管理员权限。右键 PowerShell，选「以管理员身份运行」。" }
}

if (-not ($RemotePlugin -or $OpenSSH -or $Tailscale)) {
    Write-Host "没有指定要装什么。可选：-RemotePlugin  -OpenSSH  -Tailscale"
    Write-Host "例：.\scripts\setup-windows.ps1 -RemotePlugin"
    exit 0
}

if ($RemotePlugin) {
    Write-Host "`n== 安装 DSH Remote 插件 =="
    $dsh = $null
    foreach ($p in @(
        "D:\DeepSeekharness\resources\runtime\cli\bin\dsh.cmd",
        "$env:ProgramFiles\DeepSeek Harness\resources\runtime\cli\bin\dsh.cmd"
    )) {
        if (Test-Path $p) { $dsh = $p; break }
    }
    if (-not $dsh -and (Get-Command dsh -ErrorAction SilentlyContinue)) { $dsh = "dsh" }

    if (-not $dsh) {
        Write-Host "没找到 dsh。先装 DSH 桌面端，或把 dsh 加到 PATH。"
        exit 1
    }

    Write-Host "使用：$dsh"
    & $dsh plugin --profile desktop add -w ds-harness-remote@0.6.0
    Write-Host "装完重启 DSH，再打开侧栏 Remote。"
}

if ($OpenSSH) {
    Write-Host "`n== 安装 OpenSSH Server =="
    NeedAdmin
    try {
        Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
        Start-Service sshd
        Set-Service -Name sshd -StartupType Automatic
        Write-Host "OpenSSH 已装好并启动。"
    } catch {
        Write-Host "系统组件安装失败：$($_.Exception.Message)"
        Write-Host "去 https://github.com/PowerShell/Win32-OpenSSH/releases 下 MSI 手动装。"
    }
    Write-Host "注意：Windows 的 cmd 跑不了 DSH Go 的 SSH 脚本。要 WSL，见 docs/04-ssh-wsl.md。"
}

if ($Tailscale) {
    Write-Host "`n== 安装 Tailscale =="
    NeedAdmin
    $installed = Get-Service Tailscale -ErrorAction SilentlyContinue
    if ($installed) {
        Write-Host "已经装了，服务状态：$($installed.Status)"
    } else {
        Write-Host "用 winget 试一下……"
        try {
            winget install --id Tailscale.Tailscale -e --silent --accept-package-agreements --accept-source-agreements
        } catch {
            Write-Host "winget 失败，改用手官网安装包。"
            $exe = Join-Path $env:TEMP "tailscale-setup.exe"
            Invoke-WebRequest -Uri "https://pkgs.tailscale.com/stable/tailscale-setup-latest.exe" -OutFile $exe
            Start-Process $exe -ArgumentList "/quiet" -Wait
        }
    }
    Write-Host "装完在托盘登录，记下 tailscale ip -4 的地址。"
}

Write-Host "`n完成。下一步：docs/03-remote.md（Remote）或 docs/04-ssh-wsl.md（SSH）。"
