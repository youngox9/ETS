#region Help
# ----------
<#
		Version History:

			[x] Version 1.0 - 2022/07/21
.DESCRIPTION
#>
Write-Host $PSScriptRoot
Set-Location $PSScriptRoot
"svn update" | cmd
"npm run build" | cmd


# purge expired 10 days war file
#Get-ChildItem -Path \\192.168.0.221\src\ -Include app*.* -Exclude APP.war -ErrorAction:SilentlyContinue | `
#Where-Object -FilterScript {(((get-date) - ($_.CreationTime)).days -gt 10 `
#-and $_.PsISContainer -ne $True)} | Remove-Item
# backup and copy to 194
#$date = Get-Date -format "yyyyMMdd-Hms"
#"ETS-frontend-157.ffs_batch" | cmd
"C:\Users\ianlo007\Documents\ETS-frontend-157.ffs_batch" | cmd
#Start-Sleep -Seconds 5
#Copy-Item \\192.168.0.221\src\APP.war -Destination \\192.168.0.221\src\APP.war$date 
#Copy-Item "D:\everohms\JAVA\eclipse-workspace\app\target\APP.war" -Destination \\192.168.0.221\src\APP.war