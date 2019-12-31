# Purpose: Joins a Windows host to the windomain.local domain which was created with "create-domain.ps1".
[CmdletBinding()]
param (
    [String] $ip,
    [String] $domain_dns,
    [String] $domain = "{{ad_domain_name}}",
    [String] $domain_dc_hostname = "dc",
    [parameter(Mandatory = $true)]
    [ValidateSet("server", "workstation")]
    [String] $machineType = "server",
    [String] $ouSrv = "OU=Servers,OU=Endpoints,OU=Lausanne,OU=CH,OU=Europe",
    [String] $ouWks = "OU=Workstations,OU=Endpoints,OU=Lausanne,OU=CH,OU=Europe",
    [String] $user = "vagrant",
    [String] $pass = "vagrant"
)
# BEGIN: FUNCTIONS
function Get-LDAPDomainPath {
    param(
        [string] $domain
    )

    $out = ""
    foreach ($part in $domain.split(".")) {
        if ($out) {
            $out += ",DC=$part"
        }
        else {
            $out += "DC=$part"
        }
    }
    return $out
}
# END: FUNCTIONS

# setting OU paths
$DCPath = Get-LDAPDomainPath -domain $domain
$OUSrv = "$ouSrv,$DCPath"
$OUWks = "$ouWks,$DCPath"

Write-Host 'Join the domain'

Write-Host "First, set DNS to DC to join the domain"
$newDNSServers = $domain_dns
$adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {$_.IPAddress -match $ip}
$adapters | ForEach-Object {$_.SetDNSServerSearchOrder($newDNSServers)}

Write-Host "Now join the domain"
$hostname = $(hostname)
$user = "$domain\$user"
$password = $pass | ConvertTo-SecureString  -AsPlainText -Force
$DomainCred = New-Object System.Management.Automation.PSCredential $user, $password

# Place the computer in the correct OU based on hostname
If ($machineType -eq "server") {
    Add-Computer -Server "$domain_dc_hostname.$domain" -DomainName $domain -credential $DomainCred -OUPath $OUSrv -PassThru
}
Else {
    Write-Host "Adding Win10 to the domain. Sometimes this step times out. If that happens, just run 'vagrant reload $hostname --provision'" #debug
    Add-Computer -Server "$domain_dc_hostname.$domain" -DomainName $domain -credential $DomainCred -OUPath $OUWks -PassThru
}

Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value 1
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value "vagrant"
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value "vagrant"

# Stop Windows Update
Write-Host "Disabling Windows Updates and Windows Module Services"
Set-Service wuauserv -StartupType Disabled
Stop-Service wuauserv
Set-Service TrustedInstaller -StartupType Disabled
Stop-Service TrustedInstaller
