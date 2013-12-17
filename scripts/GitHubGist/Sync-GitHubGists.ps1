[System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")

function Sync-GitHubGists{

    param(
        [string[]]$Url,
        [string]$Path
    )
    
    # settings
    $TagFileName = "Tags.txt"    
    $GithubGists = $null
    
    $Url | %{
    
        # get json
        $WebClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("user-agent", "PowerShell Scripts")
        $WebResponse = $WebClient.DownloadString($_)
        
        # json to object 
        $JavaScriptSerializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer
        $GitHubGists += $JavaScriptSerializer.DeserializeObject($WebResponse)
    }
    
    # get repos
    $GitHubGists = $GitHubGists | select  `
        @{L="Name";E={($_.description).split("#")[0] -replace "`n","" -replace "`r","" -replace "`r`n",""}}, `        @{L="Tags";E={($_.description).split("#")[1..100] | %{"#$_" -replace "`n","" -replace "`r","" -replace "`r`n",""}}}, `
        @{L="git_pull_url";E={$_.git_pull_url}}
    
    # update or create local repos
    $GitHubGists | %{
        
        $LocalGitPath = Join-Path $Path $_.Name
        
        if(Test-Path $LocalGitPath){
            
            cd ($LocalGitPath)
            Write-Host "Update GitHubGist: $($_.Name)"        
            git pull
            
        }else{
        
            $LocalGitClonePath = "`"$LocalGitPath`"" -replace "`n",""
            Write-Host "Cloning GitHubGist: $($_.Name)"   
            git clone ($_.git_pull_url) $LocalGitClonePath 
        }
        
        $TagFilePath = Join-Path $LocalGitPath $TagFileName
        if(-not (Test-Path $TagFilePath)){New-Item -Path $TagFilePath -ItemType File}        
        Set-Content -Value $_.Tags -Path $TagFilePath        
    }  
    
    # delete old repos
    Get-ChildItem -Path $Path | where{$_.psiscontainer -and (($GitHubGists | %{"$($_.Name)"}) -notcontains $_.Name)} | Remove-Item -Force -Recurse
    
}

Sync-GitHubGists -Url "https://api.github.com/users/janikvonrotz/gists?page=1", `
"https://api.github.com/users/janikvonrotz/gists?page=2", `
"https://api.github.com/users/janikvonrotz/gists?page=3", `
"https://api.github.com/users/janikvonrotz/gists?page=4" `
 -Path (Split-Path $MyInvocation.InvocationName -Parent)