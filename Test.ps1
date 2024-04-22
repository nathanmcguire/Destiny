Clear
Remove-Module Destiny
Copy-Item .\Destiny\* ~\Documents\WindowsPowerShell\Modules\Destiny\1.0\ -Recurse -Force
Import-Module Destiny
. ./MyConfiguration.ps1
New-DestinyAccessToken -Domain $Domain -Context $Context -ClientId $ClientId -ClientSecret $ClientSecret