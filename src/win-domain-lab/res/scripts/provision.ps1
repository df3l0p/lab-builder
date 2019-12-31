# Purpose: Sets timezone to UTC, sets hostname, creates/joins domain.
[CmdletBinding()]
Param (
    [String] $ip,
    [String] $domain_dns,
    [parameter(Mandatory = $true)]
    [ValidateSet("dc", "server", "workstation")]
    [String] $machineType = "server",
    [String] $domain = "{{ad_domain_name}}",
    [String] $timezone = "UTC",
    [String] $keyboard = "fr-ch"
)

$box = Get-ItemProperty -Path HKLM:SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName -Name "ComputerName"
$box = $box.ComputerName.ToString().ToLower()

# could be "W. Europe Standard Time"
Write-Host "Setting timezone to UTC"
c:\windows\system32\tzutil.exe /s $timezone

# setting french swiss keyboard
Set-WinUserLanguageList -LanguageList $keyboard, en-US -Force

if ($env:COMPUTERNAME -imatch 'vagrant') {

    Write-Host 'Hostname is still the original one, skip provisioning for reboot'
    Write-Host 'Install bginfo'
    . c:\vagrant\res\scripts\install-bginfo.ps1

    Write-Host -fore red 'Hint: vagrant reload' $box '--provision'

}
elseif ((gwmi win32_computersystem).partofdomain -eq $false) {

    Write-Host -fore red "Current domain is set to 'workgroup'. Time to join the domain!"

    if (!(Test-Path 'c:\Program Files\sysinternals\bginfo.exe')) {
        Write-Host 'Install bginfo'
        . c:\vagrant\res\scripts\install-bginfo.ps1
    }

    if ($machineType -imatch 'dc') {
        . c:\vagrant\res\scripts\create-domain.ps1 -ip $ip -domain $domain
    }
    else {
        . c:\vagrant\res\scripts\join-domain.ps1 -ip $ip -domain $domain -domain_dns $domain_dns -machineType $machineType
    }
    Write-Host -fore red 'Hint: vagrant reload' $box '--provision'

}
else {

    Write-Host -fore green "I am domain joined!"

    if (!(Test-Path 'c:\Program Files\sysinternals\bginfo.exe')) {
        Write-Host 'Install bginfo'
        . c:\vagrant\res\scripts\install-bginfo.ps1
    }

    Write-Host 'Provisioning after joining domain'

    # provisioning administrator groups on local machines
    if ($machineType -imatch 'server') {
        if (-Not (Get-LocalGroupMember -Group "Administrators" -Member "*\Server administrators")) {
            Add-LocalGroupMember -Group "Administrators" -Member "$domain\Server administrators"
        }
    }
    if ($machineType -imatch 'workstation') {
        if (-Not (Get-LocalGroupMember -Group "Administrators" -Member "*\Workstation administrators")) {
            Add-LocalGroupMember -Group "Administrators" -Member "$domain\Workstation administrators"
        }
    }
}
