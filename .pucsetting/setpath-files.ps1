# ============================================
# PUC路径自动配置脚本 (PowerShell v2 原生版)
# 版本: v4.2.0 - 位置参数，无命名参数
# 存放: <仓库根目录>\.pucsetting\setpath-files.ps1
# 用法: .\setpath-files.ps1 [目标文件名]
# ============================================

$File = if ($args.Count -gt 0) { $args[0] } else { $null }

if ($File -eq $null -or $File.Trim() -eq "") {
    Write-Output ""
    Write-Output "PUC本地路径自动配置脚本"
    Write-Output "========================="
    Write-Output ""
    Write-Output "用途：自动检测当前仓库根目录，并将指定 .puc.ini 文件中的"
    Write-Output "      GitHub_LocalPath:本地仓库路径 更新为真实的本地绝对路径。"
    Write-Output ""
    Write-Output "用法：.\setpath-files.ps1 [目标文件名]"
    Write-Output ""
    Write-Output "范例：.\setpath-files.ps1 00_README.puc.ini"
    Write-Output "      .\setpath-files.ps1 06_PUC-AI载入文档规范.puc.ini"
    Write-Output ""
    Write-Output "说明：本脚本应放置在 <仓库根目录>\.pucsetting\setpath-files.ps1"
    Write-Output "      执行时会自动向上查找仓库根目录，并优先搜索其下的 PUC 子目录，"
    Write-Output "      若未找到 PUC 子目录则直接使用根目录。"
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
    Write-Error "[错误] 找不到 PUC 配置文件: $iniFile"
    Write-Error "请确保本脚本放在 <仓库根目录>\.pucsetting\setpath-files.ps1"
    Write-Error "并指定正确的目标文件名（例如 00_README.puc.ini）"
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

Write-Output "[完成] 已将 $File 中的 GitHub_LocalPath:本地仓库路径 更新为: $newPath"