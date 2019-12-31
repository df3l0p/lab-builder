[CmdletBinding()]
param (
    [String] $pathToPawContent = "c:/vagrant/res/conf/paw_content/"
)

Set-Location $pathToPawContent
Invoke-Expression "$pathToPawContent/Create-PAWOUs.ps1"
Invoke-Expression "$pathToPawContent/Create-PAWGroups.ps1"
Invoke-Expression "$pathToPawContent/Set-PAWOUDelegation.ps1"
