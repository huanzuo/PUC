# ============================================
# PUC路径自动配置脚本 (PowerShell v2 原生版)
# 版本: v4.0.0 - 支持参数指定要修改的目标文件
# 存放: <仓库根目录>\.pucsetting\setpath.ps1
# 用法: .\setpath.ps1 [-File <目标文件名>]
#       若省略 -File，默认修改 00_README.puc.ini
# ============================================

param(
    [string]$File = "00_README.puc.ini"
)

# 1. 获取本脚本所在目录 (.pucsetting) 并推导仓库根目录
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir

# 2. 优先尝试 PUC 子目录，若不存在则回退到根目录
$pucDir = Join-Path $repoRoot "PUC"
if (Test-Path (Join-Path $pucDir $File)) {
    $iniFile = Join-Path $pucDir $File
} else {
    $pucDir = $repoRoot
    $iniFile = Join-Path $repoRoot $File
}

if (-not (Test-Path $iniFile)) {
    Write-Error "[错误] 找不到 PUC 配置文件: $iniFile"
    Write-Error "请确保本脚本放在 <仓库根目录>\.pucsetting\setpath.ps1"
    Write-Error "用法: .\setpath.ps1 [-File <目标文件名>]"
    exit 1
}

# 3. 准备路径信息 (保持 Windows 反斜杠路径)
$newPath = $pucDir
$tempFile = $iniFile + ".tmp"

try:
    # 4. 使用 StreamReader 和 StreamWriter 进行精准行替换
    $reader = [System.IO.StreamReader] $iniFile
    $writer = [System.IO.StreamWriter] $tempFile

    $line = $reader.ReadLine()
    while ($line -ne $null) {
        # 5. 精准匹配完整键名: GitHub_LocalPath:本地仓库路径
        if ($line.StartsWith("GitHub_LocalPath:本地仓库路径")) {
            $newLine = "GitHub_LocalPath:本地仓库路径 = $newPath | git clone后的本地仓库根目录(Win用反斜杠\ Unix用正斜杠/) | 更换设备时首先修改此项"
        } else {
            $newLine = $line
        }

        # 6. 检查下一行是否存在，以决定是否添加换行符
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

# 7. 用编辑好的临时文件替换原始文件
Copy-Item $tempFile $iniFile -Force
Remove-Item $tempFile -Force

Write-Output "[完成] 已将 $File 中的 GitHub_LocalPath:本地仓库路径 更新为: $newPath"