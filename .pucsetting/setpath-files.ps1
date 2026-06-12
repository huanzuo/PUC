# ============================================
# PUC 本地路径自动配置脚本 (v5.0.0 - 完全重写)
# 兼容：Windows PowerShell v2.0 ~ v5.1
# 路径：<仓库根目录>\.pucsetting\setpath.ps1
# 用法：.\setpath.ps1 [目标文件名]
#       无参数时显示此帮助
# ============================================

# --- 获取命令行参数（位置参数，不使用 param）---
$FileName = ""
if ($args.Count -gt 0) { $FileName = $args[0].Trim() }

# --- 如果参数为空，显示帮助 ---
if ([string]::IsNullOrEmpty($FileName)) {
    Write-Output ""
    Write-Output "PUC 本地路径自动配置脚本"
    Write-Output "========================="
    Write-Output "作用：自动检测当前仓库根目录，并将指定 .puc.ini 文件中的"
    Write-Output "      GitHub_LocalPath:本地仓库路径 更新为真实的绝对路径。"
    Write-Output ""
    Write-Output "用法：.\setpath.ps1 <目标文件名>"
    Write-Output ""
    Write-Output "示例：.\setpath.ps1 00_README.puc.ini"
    Write-Output "      .\setpath.ps1 06_PUC-AI载入文档规范.puc.ini"
    Write-Output ""
    Write-Output "说明：脚本应放置在 <仓库根目录>\.pucsetting\setpath.ps1"
    Write-Output "      执行时会自动向上查找仓库根目录，并优先搜索其下的 PUC 子目录，"
    Write-Output "      若未找到 PUC 子目录则直接使用根目录。"
    Write-Output ""
    exit 0
}

# --- 定位仓库根目录与目标文件 ---
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

# 优先找 PUC 子目录，否则直接使用仓库根目录
$PucDir = Join-Path $RepoRoot "PUC"
if (Test-Path (Join-Path $PucDir $FileName)) {
    $TargetFile = Join-Path $PucDir $FileName
} else {
    $PucDir = $RepoRoot
    $TargetFile = Join-Path $RepoRoot $FileName
}

if (-not (Test-Path $TargetFile)) {
    Write-Error "[错误] 找不到文件: $TargetFile"
    Write-Error "请确认文件名是否正确，或脚本是否放在仓库的 .pucsetting 文件夹内。"
    exit 1
}

# --- 准备替换值 ---
$NewPath = $PucDir
$TempFile = $TargetFile + ".tmp"

try {
    $Reader = [System.IO.StreamReader] $TargetFile
    $Writer = [System.IO.StreamWriter] $TempFile

    $Line = $Reader.ReadLine()
    while ($Line -ne $null) {
        if ($Line.StartsWith("GitHub_LocalPath:本地仓库路径")) {
            # 精确替换该行
            $NewLine = "GitHub_LocalPath:本地仓库路径 = $NewPath | git clone后的本地仓库根目录(Win用反斜杠\ Unix用正斜杠/) | 更换设备时首先修改此项"
        } else {
            $NewLine = $Line
        }

        $NextLine = $Reader.ReadLine()
        if ($NextLine -eq $null) {
            $Writer.Write($NewLine)
            break
        } else {
            $Writer.WriteLine($NewLine)
            $Line = $NextLine
        }
    }
} finally {
    if ($Reader -ne $null) { $Reader.Close() }
    if ($Writer -ne $null) { $Writer.Close() }
}

# --- 替换原文件 ---
Copy-Item $TempFile $TargetFile -Force
Remove-Item $TempFile -Force

Write-Output "[完成] 已将 $FileName 中的 GitHub_LocalPath:本地仓库路径 更新为: $NewPath"