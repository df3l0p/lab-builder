[CmdletBinding()]
param (
    [String] $ip,
    [String] $Server = "dc.{{ad_domain_name}}",
    [String] $BasePath = "{{ad_ldap_path_root}}"
)
# Purpose: Sets up the Server and Workstations OUs
Function Create-OU {
    Param (
        [String] $Name,
        [String] $Server,
        [String] $Path
    )
    if (!([ADSI]::Exists("LDAP://OU="+ $Name + "," + $Path)))
    {
        New-ADOrganizationalUnit -Name $Name -Server $Server -Path $Path
    }
    else
    {
        Write-Host "$Name OU ($Path) already exists. Moving On."
    }
}

Write-Host "Creating Server and Workstation OUs..."
Write-Host "Creating Servers OU..."
Write-Host "BasePath: $BasePath"
Create-OU -Name "Servers" -Path $BasePath -Server $Server
Create-OU -Name "Europe" -Path $BasePath -Server $Server
Create-OU -Name "CH" -Path "OU=Europe,$BasePath" -Server $Server
Create-OU -Name "Lausanne" -Path "OU=CH,OU=Europe,$BasePath" -Server $Server
Create-OU -Name "Endpoints" -Path "OU=Lausanne,OU=CH,OU=Europe,$BasePath" -Server $Server
Create-OU -Name "Servers" -Path "OU=Endpoints,OU=Lausanne,OU=CH,OU=Europe,$BasePath" -Server $Server
Create-OU -Name "Special" -Path "OU=Endpoints,OU=Lausanne,OU=CH,OU=Europe,$BasePath" -Server $Server
Create-OU -Name "Workstations" -Path "OU=Endpoints,OU=Lausanne,OU=CH,OU=Europe,$BasePath" -Server $Server
Create-OU -Name "Users and Groups" -Path "OU=Lausanne,OU=CH,OU=Europe,$BasePath" -Server $Server
Create-OU -Name "Groups" -Path "OU=Users and Groups,OU=Lausanne,OU=CH,OU=Europe,$BasePath" -Server $Server
Create-OU -Name "Users" -Path "OU=Users and Groups,OU=Lausanne,OU=CH,OU=Europe,$BasePath" -Server $Server
Create-OU -Name "adm_acct" -Path "OU=Users,OU=Users and Groups,OU=Lausanne,OU=CH,OU=Europe,$BasePath" -Server $Server
Create-OU -Name "std_acct" -Path "OU=Users,OU=Users and Groups,OU=Lausanne,OU=CH,OU=Europe,$BasePath" -Server $Server
Create-OU -Name "svc_acct" -Path "OU=Users,OU=Users and Groups,OU=Lausanne,OU=CH,OU=Europe,$BasePath" -Server $Server
#if (!([ADSI]::Exists("LDAP://OU=Europe,$Path")))
#{
#    New-ADOrganizationalUnit -Name "Europe" -Server "dc.windomain.local"
#}
#else
#{
#    Write-Host "Europe OU already exists. Moving On."
#}
#if (!([ADSI]::Exists("LDAP://OU=Servers,$Path")))
#{
#    New-ADOrganizationalUnit -Name "Servers" -Server "dc.windomain.local"
#}
#else
#{
#    Write-Host "Servers OU already exists. Moving On."
#}
#Write-Host "Creating Workstations OU"
#if (!([ADSI]::Exists("LDAP://OU=Workstations,$Path")))
#{
#    New-ADOrganizationalUnit -Name "Workstations" -Server "dc.windomain.local"
#}
#else
#{
#    Write-Host "Workstations OU already exists. Moving On."
#}
# Sysprep breaks auto-login. Let's restore it here:
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value 1
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value "vagrant"
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value "vagrant"
