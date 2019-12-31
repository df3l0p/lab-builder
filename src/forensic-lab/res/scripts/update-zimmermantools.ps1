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

Copy-Item -Force -Recurse -Path C:\vagrant\res\scripts\Get-ZimmermanTools $Dest

Set-Location -Path "$Dest\Get-ZimmermanTools"
Invoke-Expression -Command "$Dest\Get-ZimmermanTools\Get-ZimmermanTools.ps1"