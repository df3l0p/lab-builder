<#
.SYNOPSIS
    This script will discover and download all available programs from https://ericzimmerman.github.io and download them to $Dest
.DESCRIPTION
    A file will also be created in $Dest that tracks the SHA-1 of each file, so rerunning the script will only download new versions. To redownload, remove lines from or delete the CSV file created under $Dest and rerun.
.PARAMETER Dest
    The path you want to save the programs to.
.EXAMPLE
    C:\PS> Get-ZimmermanTools.ps1 -Dest c:\tools
    Downloads/extracts and saves details about programs to c:\tools directory.
.NOTES
    Author: Eric Zimmerman
    Date:   January 22, 2019    
#>

[Cmdletbinding()]
# Where to extract the files to
Param
(
    [Parameter()]
    [string]$Dest= (Resolve-Path ".") #Where to save programs to	
)

$FinalDest = "$Dest\ZimmermanTools"

New-Item -Force -Path "$FinalDest" -ItemType "directory"
Write-Host "Downloading Get-ZimmermanTools downloader"
$scriptFile = $FinalDest + "\Get-ZimmermanTools.ps1"
(New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/EricZimmerman/Get-ZimmermanTools/master/Get-ZimmermanTools.ps1", $scriptFile)

Set-Location -Path "$FinalDest"
## running update of tools
Invoke-Expression -Command "$scriptFile"


## Setting PATH
$oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
if (-not ($oldpath -like "*$FinalDest*")) {
    Write-Host "Adding $FinalDest to PATH"
    $newpath = "$oldpath;$FinalDest"
    Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath
}