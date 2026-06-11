# ============================================
# PUC路径自动配置脚本 (PowerShell v2 原生版)
# 版本: v3.0.0 - 使用StreamReader/Writer精准行替换
# 存放: <仓库根目录>\.pucsetting\setpath.ps1
# ============================================

# 1. 获取本脚本所在目录 (.pucsetting) 并推导仓库根目录
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir

# 2. 优先尝试 PUC 子目录，若不存在则回退到根目录
$pucDir = Join-Path $repoRoot "PUC"
if (Test-Path (Join-Path $pucDir "00_README.puc.ini")) {
    $iniFile = Join-Path $pucDir "00_README.puc.ini"
} else {
    $pucDir = $repoRoot
    $iniFile = Join-Path $repoRoot "00_README.puc.ini"
}

if (-not (Test-Path $iniFile)) {
    Write-Error "[错误] 找不到 PUC 配置文件: $iniFile"
    Write-Error "请确保本脚本放在 <仓库根目录>\.pucsetting\setpath.ps1"
    exit 1
}

# 3. 准备路径信息
$newPath = $pucDir -replace "\\", "/" # 将Windows路径分隔符转为正斜杠，以统一格式
$tempFile = $iniFile + ".tmp" # 临时文件路径，用于安全写入

try {
    # 4. 使用StreamReader读取，StreamWriter写入临时文件
    $reader = [System.IO.StreamReader] $iniFile
    $writer = [System.IO.StreamWriter] $tempFile

    $line = $reader.ReadLine()
    while ($line -ne $null) {
        # 5. 精准定位：如果行以目标键名开头，则替换整行内容
        if ($line.StartsWith("GitHub_LocalPath:")) {
            # 重组目标行，保留键名，替换为新路径，并附加统一的注释后缀
            $newLine = "GitHub_LocalPath:" + $newPath + " | git clone后的本地仓库根目录(Win用反斜杠\ Unix用正斜杠/) | 更换设备时首先修改此项"
            $writer.WriteLine($newLine)
        } else {
            # 其他行原封不动地写入临时文件
            $writer.WriteLine($line)
        }
        $line = $reader.ReadLine()
    }
} finally {
    # 确保无论发生什么，文件句柄都会被关闭
    if ($reader -ne $null) { $reader.Close() }
    if ($writer -ne $null) { $writer.Close() }
}

# 6. 安全替换：用编辑好的临时文件替换原始文件
Copy-Item $tempFile $iniFile -Force
Remove-Item $tempFile -Force

Write-Output "[完成] 已将 GitHub_LocalPath 更新为: $newPath"