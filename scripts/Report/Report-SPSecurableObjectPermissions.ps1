param([switch]$OutPutToGridView)

$Metadata = @{
	Title = "Report SharePoint Securable Object Permissions"
	Filename = "Report-SPSecurableObjectPermissions.ps1"
	Description = ""
	Tags = "powershell, sharepoint, function, report"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-03-14"
	LastEditDate = "2013-05-15"
	Version = "1.1.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

<#
.EXAMPLE    
    .\Report-SPSecurableObjectPermissions -OutPutToGreadView
    
.EXAMPLE  
    $Report = .\Report-SPSecurableObjectPermissions.ps1 -OutPutToGreadView
#>

#--------------------------------------------------#
# Includes
#--------------------------------------------------#
if ((Get-PSSnapin “Microsoft.SharePoint.PowerShell” -ErrorAction SilentlyContinue) -eq $null) {
    Add-PSSnapin “Microsoft.SharePoint.PowerShell”
}

#--------------------------------------------------#
# functions and inits
#--------------------------------------------------#

$SPSecurableObjectPermissionReport = @()

function New-SPReportItem {
    param(
        $Name,
        $Url,
        $Member,
        $Permission,
        $Type
    )
    New-Object PSObject -Property @{
        Name = $Name
        Url = $Url
        Member = $Member
        Permission =$Permission
        Type =$Type
    }
}

#--------------------------------------------------#
# Main
#--------------------------------------------------#
# Get all Webapplictons
$SPWebApp = Get-SPWebApplication

# Get all sites
$SPSites = $SPWebApp | Get-SPsite -Limit all 

foreach($SPSite in $SPSites){

    # Get all websites
    $SPWebs = $SPSite | Get-SPWeb -Limit all

    #Loop through each subsite and write permissions
    foreach ($SPWeb in $SPWebs){

        Write-Progress -Activity "Read Permissions" -status $SPWeb -percentComplete ([int]([array]::IndexOf($SPWebs, $SPWeb)/$SPWebs.Count*100))
            
        if (($SPWeb.permissions -ne $null) -and  ($SPWeb.HasUniqueRoleAssignments)){          
            foreach ($RoleAssignment in $SPWeb.RoleAssignments){
            
                $Member =  $RoleAssignment.Member.UserLogin -replace "VBL\\",""
                $Permission = $RoleAssignment.roledefinitionbindings[0].Name
                
                $SPSecurableObjectPermissionReport += New-SPReportItem -Name $SPWeb -Url $SPWeb.url -Member $Member -Permission $Permission -Type "Website"
            }        
        }
        
        foreach ($SPlist in $SPWeb.lists){
            
            if (($SPlist.permissions -ne $null) -and ($SPlist.HasUniqueRoleAssignments)) {        
                foreach ($RoleAssignment in $SPlist.RoleAssignments){
                
                    $SPListUrl = $SPWeb.url + "/" + $SPlist.Title 
                    $Member =  $RoleAssignment.Member.UserLogin -replace "VBL\\",""
                    $Permission = $RoleAssignment.roledefinitionbindings[0].Name
                    
                    $SPSecurableObjectPermissionReport += New-SPReportItem -Name $SPlist.Title -Url $SPListUrl -Member $Member -Permission $Permission -Type "List"
                }
            }
        }
    }
}

if($OutPutToGridView){

    $SPSecurableObjectPermissionReport | Out-GridView
    
    Write-Host "`nFinished" -BackgroundColor Black -ForegroundColor Green
    Read-Host "`nPress Enter to exit"

}else{

    return $SPSecurableObjectPermissionReport
    
}