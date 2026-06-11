# ============================================
# PUC路径自动配置脚本 (PowerShell v2 兼容)
# 版本: v1.0.1 - 自动适配根目录 / PUC子目录两种结构
# 存放: <仓库根目录>\.pucsetting\setpath.ps1
# ============================================

# 获取本脚本所在目录 (.pucsetting)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir

# 优先尝试 PUC 子目录，若不存在则回退到根目录
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

$lines = Get-Content $iniFile
$targetSection = "[PUC\LAUNCH\Environment]"
$targetKey = "GitHub_LocalPath"
$newValue = $pucDir -replace "\\", "/"
$inTargetSection = $false
$modified = $false

for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i].Trim()
    if ($line -match "^\[.*\]$") {
        $inTargetSection = ($line -eq $targetSection)
        continue
    }
    if ($inTargetSection -and ($line -match "^$targetKey\s*:")) {
        $prefix = $lines[$i].Substring(0, $lines[$i].IndexOf(":") + 1)
        $lines[$i] = "$prefix$newValue | git clone后的本地仓库根目录(Win用反斜杠\ Unix用正斜杠/) | 更换设备时首先修改此项"
        $modified = $true
        break
    }
}

if ($modified) {
    $lines | Set-Content $iniFile
    Write-Output "[完成] 已将 $targetSection 中的 $targetKey 更新为: $newValue"
} else {
    Write-Error "[警告] 未找到配置项 $targetKey，请检查 $iniFile 文件结构"
}