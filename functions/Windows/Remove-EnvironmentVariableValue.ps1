<#
$Metadata = @{
	Title = "Remove Environment Variable Value"
	Filename = "Remove-EnvironmentVariableValue.ps1"
	Description = ""
	Tags = "powershell, function, remove, environment, vairable"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2014-02-21"
	LastEditDate = "2014-02-21"
	Url = ""
	Version = "0.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Remove-EnvironmentVariableValue{

<#
.SYNOPSIS
    Removes value of an environment variable.

.DESCRIPTION
	Removes value of an environment variable.

.PARAMETER Name
	Name of the variable.

.PARAMETER Value
	Value to remove.
    
.PARAMETER Target
    Scope of the variable. Machine or User.
    
.PARAMETER Clear
    Clear this variable.

.EXAMPLE
	PS C:\> Remove-EnvironmentVariableValue -Name Path -Value "C:\bin" -Target Machine

#>

    [CmdletBinding()]
    param(

		[Parameter(Mandatory=$true)]
		[String]
		$Name,
        
		[Parameter(Mandatory=$true)]
		[String]
		$Value, 
         
		[Parameter(Mandatory=$true)]
		[String]
		$Target,  

		[Switch]
		$Clear  
	)  
  
    #--------------------------------------------------#
    # main
    #--------------------------------------------------#

    [Environment]::GetEnvironmentVariable($Name,$Target) | %{
                
        if($_.Contains($Value) -and -not $Clear){
            
            Write-Host "Remove value: $Value from variable: $Name"            
            [Environment]::SetEnvironmentVariable($Name,$_.Trim($Value),$Target)
        
        }elseif($Clear){
        
            Write-Host "Set value: $Value on variable: $Name"
            [Environment]::SetEnvironmentVariable($Name,$null,$Target)            
        }
    }     
}       