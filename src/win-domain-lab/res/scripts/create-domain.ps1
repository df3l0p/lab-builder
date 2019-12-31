[CmdletBinding()]
param (
    [String] $ip,
    [String] $domain = "{{ad_domain_name}}",
    [String] $pass = "vagrant"
)

$subnet = $ip -replace "\.\d+$", ""

if ((gwmi win32_computersystem).partofdomain -eq $false) {

    Write-Host 'Installing RSAT tools'
    Import-Module ServerManager
    Add-WindowsFeature RSAT-AD-PowerShell, RSAT-AD-AdminCenter

    Write-Host 'Creating domain controller'
    # Disable password complexity policy
    secedit /export /cfg C:\secpol.cfg
    (Get-Content C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
    secedit /configure /db C:\Windows\security\local.sdb /cfg C:\secpol.cfg /areas SECURITYPOLICY
    rm -force C:\secpol.cfg -confirm:$false

    # Set administrator password
    $computerName = $env:COMPUTERNAME
    $adminPassword = $pass
    $adminUser = [ADSI] "WinNT://$computerName/Administrator,User"
    $adminUser.SetPassword($adminPassword)

    $PlainPassword = $pass # "P@ssw0rd"
    $SecurePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force

    # Windows Server 2019
    Install-WindowsFeature AD-domain-services -IncludeManagementTools
    Import-Module ADDSDeployment
    # No ForestMode/DomainMode to use the forestlevel of the box used

    Install-ADDSForest `
        -SafeModeAdministratorPassword $SecurePassword `
        -CreateDnsDelegation:$false `
        -DatabasePath "C:\Windows\NTDS" `
        -DomainMode "7" `
        -DomainName $domain `
        -DomainNetbiosName $($domain.split(".")[0].ToUpper()) `
        -ForestMode "7" `
        -InstallDns:$true `
        -LogPath "C:\Windows\NTDS" `
        -NoRebootOnCompletion:$true `
        -SysvolPath "C:\Windows\SYSVOL" `
        -Force:$true

    <# $newDNSServers = "9.9.9.9", "1.1.1.1"
    $adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress -And ($_.IPAddress).StartsWith($subnet) }
    if ($adapters) {
        Write-Host Setting DNS
        $adapters | ForEach-Object {$_.SetDNSServerSearchOrder($newDNSServers)}
    } #>
    Write-Host "Setting timezone to UTC"
    c:\windows\system32\tzutil.exe /s "UTC"
  
    <# Write-Host "Excluding NAT interface from DNS"
    $nics = Get-WmiObject "Win32_NetworkAdapterConfiguration where IPEnabled='TRUE'" |? { $_.IPAddress[0] -ilike "172.25.*" }
    $dnslistenip = $nics.IPAddress
    $dnslistenip
    dnscmd /ResetListenAddresses  $dnslistenip

    $nics = Get-WmiObject "Win32_NetworkAdapterConfiguration where IPEnabled='TRUE'" |? { $_.IPAddress[0] -ilike "10.*" }
    foreach ($nic in $nics) {
        $nic.DomainDNSRegistrationEnabled = $false
        $nic.SetDynamicDNSRegistration($false) |Out-Null
    }


    #Get-DnsServerResourceRecord -ZoneName $domain -type 1 -Name "@" |Select-Object HostName,RecordType -ExpandProperty RecordData |Where-Object {$_.IPv4Address -ilike "10.*"}|Remove-DnsServerResourceRecord
    $RRs = Get-DnsServerResourceRecord -ZoneName $domain -type 1 -Name "@"

    foreach ($RR in $RRs) {
        if ( (Select-Object  -InputObject $RR HostName, RecordType -ExpandProperty RecordData).IPv4Address -ilike "10.*") { 
            Remove-DnsServerResourceRecord -ZoneName $domain -RRType A -Name "@" -RecordData $RR.RecordData.IPv4Address -Confirm
        }

    }
    Restart-Service DNS #>

    #$file = "$env:windir\System32\drivers\etc\hosts"
    #"$ip $domain" | Add-Content -PassThru $file
  
}
