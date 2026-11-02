# 只读检查：这台 Windows 适不适合跑 DSH / DSH Go
# 用法：powershell -ExecutionPolicy Bypass -File .\scripts\check-windows.ps1

$ErrorActionPreference = "SilentlyContinue"

function Line($k, $v) {
    "{0,-22} {1}" -f $k, $v
}

"== 系统 =="
$osVer = [System.Environment]::OSVersion.Version.ToString()
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Line "Windows" $osVer
Line "用户" $env:USERNAME
Line "管理员" $isAdmin

"`n== 运行环境 =="
$node = Get-Command node
$npm = Get-Command npm
$nodeVer = "未安装"
if ($node) { $nodeVer = (& node -v) }
$npmVer = "未安装"
if ($npm) { $npmVer = (& npm -v) }
Line "Node" $nodeVer
Line "npm" $npmVer

"`n== DSH =="
$desktopDir = "D:\DeepSeekharness"
$dshCmd = $null
foreach ($p in @(
    "D:\DeepSeekharness\resources\runtime\cli\bin\dsh.cmd",
    "$env:ProgramFiles\DeepSeek Harness\resources\runtime\cli\bin\dsh.cmd"
)) {
    if (Test-Path $p) { $dshCmd = $p; break }
}
$desktopState = "未找到"
if (Test-Path $desktopDir) { $desktopState = $desktopDir }
Line "桌面端目录" $desktopState
Line "自带 CLI" ($(if ($dshCmd) { $dshCmd } else { "未找到" }))

$pathDsh = Get-Command dsh
$pathDshState = "没有"
if ($pathDsh) { $pathDshState = $pathDsh.Source }
Line "PATH 里的 dsh" $pathDshState

$profilePath = Join-Path $env:USERPROFILE ".dsh\profiles\desktop\node_modules\ds-harness-remote"
$pluginState = "未安装"
if (Test-Path $profilePath) { $pluginState = "已安装" }
Line "Remote 插件" $pluginState

"`n== 远程访问 =="
$sshd = Get-Service sshd
$sshdState = "未安装"
if ($sshd) { $sshdState = $sshd.Status }
Line "sshd" $sshdState

$listen = Get-NetTCPConnection -LocalPort 22 -State Listen
if ($listen) {
    $addrs = ($listen | ForEach-Object { "$($_.LocalAddress):22" }) -join ", "
    Line "22 端口" $addrs
} else {
    Line "22 端口" "没有监听"
}

$ts = Get-Command tailscale
if ($ts) {
    $tsIp = (& tailscale ip -4 2>$null)
    Line "Tailscale" $tsIp
} else {
    Line "Tailscale" "未安装"
}

"`n== 进程 =="
$procs = Get-Process | Where-Object { $_.ProcessName -like "*DeepSeek*" }
Line "DSH 进程数" (@($procs).Count)

"`n提示：这只做检查，不改任何东西。要装东西看 docs/01-pc-dsh.md 和 docs/04-ssh-wsl.md。"
