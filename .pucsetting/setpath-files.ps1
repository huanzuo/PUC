@'
# ============================================
# PUC路径自动配置脚本 (PowerShell v2 原生版)
# 版本: v4.2.1 - 完全移除命名参数，仅使用位置参数
# 用法: .\setpath-files.ps1 [目标文件名]
# 示例: .\setpath-files.ps1 00_README.puc.ini
# ============================================

$File = if ($args.Count -gt 0) { $args[0] } else { $null }

if ($File -eq $null -or $File.Trim() -eq "") {
    Write-Output ""
    Write-Output "PUC本地路径自动配置脚本"
    Write-Output "========================="
    Write-Output ""
    Write-Output "用途：更新 .puc.ini 文件中的 GitHub_LocalPath:本地仓库路径"
    Write-Output ""
    Write-Output "用法：.\setpath-files.ps1 [目标文件名]"
    Write-Output ""
    Write-Output "范例：.\setpath-files.ps1 00_README.puc.ini"
    Write-Output "      .\setpath-files.ps1 06_PUC-AI载入文档规范.puc.ini"
    Write-Output ""
    exit 0
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir

$pucDir = Join-Path $repoRoot "PUC"
if (Test-Path (Join-Path $pucDir $File)) {
    $iniFile = Join-Path $pucDir $File
} else {
    $pucDir = $repoRoot
    $iniFile = Join-Path $repoRoot $File
}

if (-not (Test-Path $iniFile)) {
    Write-Error "[错误] 找不到文件: $iniFile"
    exit 1
}

$newPath = $pucDir
$tempFile = $iniFile + ".tmp"

try {
    $reader = [System.IO.StreamReader] $iniFile
    $writer = [System.IO.StreamWriter] $tempFile

    $line = $reader.ReadLine()
    while ($line -ne $null) {
        if ($line.StartsWith("GitHub_LocalPath:本地仓库路径")) {
            $newLine = "GitHub_LocalPath:本地仓库路径 = $newPath | git clone后的本地仓库根目录(Win用反斜杠\ Unix用正斜杠/) | 更换设备时首先修改此项"
        } else {
            $newLine = $line
        }

        $nextLine = $reader.ReadLine()
        if ($nextLine -eq $null) {
            $writer.Write($newLine)
            break
        } else {
            $writer.WriteLine($newLine)
            $line = $nextLine
        }
    }
} finally {
    if ($reader -ne $null) { $reader.Close() }
    if ($writer -ne $null) { $writer.Close() }
}

Copy-Item $tempFile $iniFile -Force
Remove-Item $tempFile -Force

Write-Output "[完成] 已更新: $newPath"
'@ | Set-Content .pucsetting\setpath-files.ps1