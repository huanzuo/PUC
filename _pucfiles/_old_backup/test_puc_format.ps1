# 测试正确的PUC对齐格式
$dateStr = Get-Date -Format "yyyy-MM-dd HH:mm"
$lunarDate = "癸卯年·二月·廿七「春分」·辰时三刻"

# 创建一个模拟日志
$logContent = @"
<101-2>[窗口切换] 窗口:PowerShell = 09:30:00 | 09:31:00 | 60000

*[$dateStr|System]
*[$dateStr|Local]
*[$lunarDate|农历]
对齐完毕！

<102-2>[窗口切换] 窗口:记事本 = 09:31:00 | 09:32:00 | 60000

*[$dateStr|System]
*[$dateStr|Local]
*[$lunarDate|农历]
对齐完毕！
"@

Write-Host "生成的PUC对齐格式示例："
Write-Host ""
Write-Host $logContent

# 保存到文件
$logContent | Out-File -FilePath "D:\Share\AI_Files\test_puc_log.log" -Encoding UTF8
Write-Host ""
Write-Host "日志已保存到: D:\Share\AI_Files\test_puc_log.log"