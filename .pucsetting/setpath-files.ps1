# ============================================
# PUC路径自动配置脚本 (PowerShell v2 原生版)
# 版本: v4.1.0 - 无参数时显示帮助；支持参数指定目标文件
# 存放: <仓库根目录>\.pucsetting\setpath.ps1
# 用法: .\setpath.ps1 -File <目标文件名>
# ============================================

param(
    [string]$File
)

# ===== 无参数时显示帮助信息 =====
if (-not $File) {
    Write-Output ""
    Write-Output "PUC本地路径自动配置脚本"
    Write-Output "========================="
    Write-Output ""
    Write-Output "用途：自动检测当前仓库根目录，并将指定 .puc.ini 文件中的"
    Write-Output "      GitHub_LocalPath:本地仓库路径 更新为真实的本地绝对路径。"
    Write-Output ""
    Write-Output "用法：.\setpath.ps1 -File <目标文件名>"
    Write-Output ""
    Write-Output "范例：.\setpath.ps1 -File 00_README.puc.ini"
    Write-Output "      .\setpath.ps1 -File 06_PUC-AI载入文档规范.puc.ini"
    Write-Output ""
    Write-Output "说明：本脚本应放置在 <仓库根目录>\.pucsetting\setpath.ps1"
    Write-Output "      执行时会自动向上查找仓库根目录，并优先搜索其下的 PUC 子目录，"
    Write-Output "      若未找到 PUC 子目录则直接使用根目录。"
    Write-Output ""
    exit 0
end

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
    Write-Error "并指定正确的目标文件名（例如 00_README.puc.ini）"
    exit 1
end

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
end

# 7. 用编辑好的临时文件替换原始文件
Copy-Item $tempFile $iniFile -Force
Remove-Item $tempFile -Force

Write-Output "[完成] 已将 $File 中的 GitHub_LocalPath:本地仓库路径 更新为: $newPath"