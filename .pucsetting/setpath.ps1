# ============================================
# PUC路径自动配置脚本 (PowerShell v2 兼容)
# 版本: v1.0.0
# 用途: 自动检测PUC仓库本地路径，更新00_README.puc.ini中的GitHub_LocalPath
# 存放: <仓库根目录>\.pucsetting\setpath.ps1
# ============================================

# 获取本脚本所在目录 (xxx\.pucsetting)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 脚本所在目录的上级目录就是仓库根目录 (xxx)
$repoRoot = Split-Path -Parent $scriptDir

# PUC规范主目录
$pucDir = Join-Path $repoRoot "PUC"
$iniFile = Join-Path $pucDir "00_README.puc.ini"

# 检查目标文件是否存在
if (-not (Test-Path $iniFile)) {
    Write-Error "[错误] 找不到PUC配置文件: $iniFile"
    Write-Error "请确保本脚本放在 <仓库根目录>\.pucsetting\setpath.ps1"
    exit 1
}

# 读取当前INI内容
$lines = Get-Content $iniFile
$targetSection = "[PUC\LAUNCH\Environment]"
$targetKey = "GitHub_LocalPath"
$newValue = $pucDir -replace "\\", "/"
$inTargetSection = $false
$modified = $false

# 逐行扫描并修改
for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i].Trim()
    
    # 检测节名
    if ($line -match "^\[.*\]$") {
        $inTargetSection = ($line -eq $targetSection)
        continue
    }
    
    # 在目标节中查找目标键
    if ($inTargetSection -and ($line -match "^$targetKey\s*:")) {
        $prefix = $lines[$i].Substring(0, $lines[$i].IndexOf(":") + 1)
        $lines[$i] = "$prefix$newValue | git clone后的本地仓库根目录(Win用反斜杠\ Unix用正斜杠/) | 更换设备时首先修改此项"
        $modified = $true
        break
    }
}

# 写回文件
if ($modified) {
    $lines | Set-Content $iniFile
    Write-Output "[完成] 已将 $targetSection 中的 $targetKey 更新为: $newValue"
} else {
    Write-Error "[警告] 未找到配置项 $targetKey，请检查 $iniFile 文件结构"
}