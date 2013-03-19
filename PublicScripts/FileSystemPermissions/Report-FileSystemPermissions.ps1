param([switch]$OutPutToGridView, [parameter(Mandatory=$true)][String]$Path, [parameter(Mandatory=$true)][int]$Levels)

$Metadata = @{
	Title = "Report Filesystem Permissions"
	Filename = "Report-FileSystemPermissions.ps1"
	Description = ""
	Tags = "powershell, function, report"
	Project = ""
	Author = "Janik von Rotz"
	AuthorEMail = "contact@janikvonrotz.ch"
	CreateDate = "2013-03-14"
	LastEditDate = "2013-03-19"
	Version = "1.0.1"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

<#
#--------------------------------------------------#
# Example
#--------------------------------------------------#
 
.\Report-FileSystemPermissions -OutPutToGridView -Path "D:\Dat" -Levels 3

$Report = .\Report-FileSystemPermissions.ps1 -Path "D:\Dat" -Levels 3

#>

#--------------------------------------------------#
# Main
#--------------------------------------------------#

$FileSystemPermissionReport = @()

function New-SPReportItem {
    param(
        $Name,
        $Url,
        $Member,
        $PermissionMask,
        $Type
    )
    New-Object PSObject -Property @{
        Name = $Name
        Url = $Url
        Member = $Member
        PermissionMask =$PermissionMask
        Type =$Type
    }
}

$FSfolders = Get-ChildItemRecurse -Path $Path -Levels $Levels -OnlyDirectories

foreach ($FSfolder in $FSfolders)
{
   $Acls = Get-Acl -Path $FSfolder.Fullname
   foreach($Acl in $Acls.Access){
       if($Acl.IsInherited -eq $false){
            $FileSystemPermissionReport += New-SPReportItem -Name $FSfolder.Name -Url $FSfolder.FullName -Member $Acl.IdentityReference -PermissionMask $Acl.FileSystemRights   -Type "Folder"
       }else{break}
   }
}

if($OutPutToGridView -eq $true){
    $FileSystemPermissionReport | Out-GridView
	Write-Host "`nFinished" -BackgroundColor Green -ForegroundColor Black
	Read-Host "`nPress Enter to exit"
}else{
    return $FileSystemPermissionReport
}