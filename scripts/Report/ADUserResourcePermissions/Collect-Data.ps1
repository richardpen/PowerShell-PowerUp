$s1 = rps sp1
$s2 = rps data1

$Report1 = Invoke-Command -Session $s1 -ScriptBlock {D:\Powershell-Profile\scripts\SharePoint\Report-SPSecurableObjectPermissions.ps1}
$Report2 = Invoke-Command -Session $s2 -ScriptBlock {(C:\Powershell-Profile\scripts\Windows\Report-FileSystemPermissions.ps1 -Path "F:\Dat" -Levels 3)}

$GroupPermissionReports = $Report1 + $Report2

$GroupPermissionReports | Export-Csv "GroupPermissionReports.csv" -Delimiter ";" -Encoding UTF8