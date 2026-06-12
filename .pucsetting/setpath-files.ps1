# ============================================
# PUC 本地路径自动配置脚本 (v5.0.1)
# 兼容：Windows PowerShell v2.0 ~ v5.1
# 路径：<仓库根目录>\.pucsetting\setpath-files.ps1
# 用法：.\setpath-files.ps1 [目标文件名]
# ============================================

# --- 获取命令行参数 ---
$FileName = ""
if ($args.Count -gt 0) { $FileName = $args[0].Trim() }

# --- 显示帮助 ---
if ([string]::IsNullOrEmpty($FileName)) {
    Write-Output ""
    Write-Output "PUC 本地路径自动配置脚本"
    Write-Output "========================="
    Write-Output "作用：更新 .puc.ini 文件中的 GitHub_LocalPath:本地仓库路径"
    Write-Output ""
    Write-Output "用法：.\setpath-files.ps1 <目标文件名>"
    Write-Output ""
    Write-Output "示例：.\setpath-files.ps1 00_README.puc.ini"
    Write-Output "      .\setpath-files.ps1 DeepSeek-TUI-Launch.puc.ini"
    Write-Output ""
    Write-Output "说明：脚本会先在当前目录(PWD)查找文件，再去仓库的 PUC 子目录查找。"
    Write-Output ""
    exit 0
}

# --- 定位仓库根目录与目标文件 ---
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

# 1. 首先，检查文件是否就在当前工作目录 (PWD)
$CurrentDir = (Get-Location).Path
if (Test-Path (Join-Path $CurrentDir $FileName)) {
    $TargetFile = Join-Path $CurrentDir $FileName
    $PucDir = $CurrentDir
}
# 2. 其次，检查仓库根目录下的 PUC 子目录
elseif (Test-Path (Join-Path $RepoRoot "PUC" $FileName)) {
    $TargetFile = Join-Path $RepoRoot "PUC" $FileName
    $PucDir = Join-Path $RepoRoot "PUC"
}
# 3. 然后，检查仓库根目录本身
elseif (Test-Path (Join-Path $RepoRoot $FileName)) {
    $TargetFile = Join-Path $RepoRoot $FileName
    $PucDir = $RepoRoot
}
# 4. 都没找到，报错
else {
    Write-Error "[错误] 找不到文件: $FileName"
    Write-Error "已尝试路径:"
    Write-Error "  当前目录: $CurrentDir"
    Write-Error "  仓库PUC子目录: $(Join-Path $RepoRoot 'PUC')"
    Write-Error "  仓库根目录: $RepoRoot"
    Write-Error "请确认文件名正确，或切换到文件所在目录后重试。"
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