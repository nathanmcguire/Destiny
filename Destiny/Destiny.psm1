Using module /Users/mcguiren/Documents/GitHub/Destiny/Destiny/Destiny/Classes/DestinyAccessToken.ps1
Using module /Users/mcguiren/Documents/GitHub/Destiny/Destiny/Destiny/Classes/DestinyError.ps1
Using module /Users/mcguiren/Documents/GitHub/Destiny/Destiny/Destiny/Classes/DestinyOAuthError.ps1

$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$Schema = @( Get-ChildItem -Path $PSScriptRoot\Schema\*.ps1 -Recurse -ErrorAction SilentlyContinue )

Foreach ($import in @($Public + $Private + $Schema)) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

Export-ModuleMember -Function $Public.Basename

#Import-Module ./Destiny