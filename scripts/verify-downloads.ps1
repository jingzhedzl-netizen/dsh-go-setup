# 按 manifest/packages.json 校验下载文件
# 用法：powershell -ExecutionPolicy Bypass -File .\scripts\verify-downloads.ps1 -Directory .\downloads

param(
    [string]$Directory = ".\downloads"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$manifestPath = Join-Path $root "manifest\packages.json"

if (-not (Test-Path $manifestPath)) { throw "找不到 $manifestPath" }
if (-not (Test-Path $Directory)) { throw "找不到下载目录 $Directory" }

$manifest = Get-Content $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$fail = 0

foreach ($pkg in $manifest.packages) {
    if (-not $pkg.file -or -not $pkg.sha256) { continue }
    $path = Join-Path $Directory $pkg.file
    if (-not (Test-Path $path)) {
        Write-Host "[缺失] $($pkg.name)  $($pkg.file)"
        $fail++
        continue
    }
    $size = (Get-Item $path).Length
    $hash = (Get-FileHash $path -Algorithm SHA256).Hash.ToLower()
    $okSize = ($pkg.size -eq 0) -or ($size -eq $pkg.size)
    $okHash = ($hash -eq $pkg.sha256.ToLower())

    if ($okHash -and $okSize) {
        Write-Host "[通过] $($pkg.name)  $($pkg.version)"
    } else {
        Write-Host "[失败] $($pkg.name)  $($pkg.file)"
        Write-Host "       大小 期望 $($pkg.size)，实际 $size"
        Write-Host "       哈希 期望 $($pkg.sha256)"
        Write-Host "       哈希 实际 $hash"
        $fail++
    }
}

if ($fail -gt 0) {
    Write-Host "`n有 $fail 个文件没通过。重新下载，别用来源不明的包。"
    exit 1
}

Write-Host "`n全部通过。"
