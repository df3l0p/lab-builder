# purpose: create a domain adin user, an admin and a regular user
[CmdletBinding()]
Param (
    [String] $username_base = "myuser",
    [String] $pass = "userpass",
    [String] $grp_srv_adm = "Server Administrators",
    [String] $grp_wks_adm = "Workstation Administrators",
    [String] $OUBasePath = "{{ad_ldap_path_root}}",
    [String] $ou_adm_acct = "OU=adm_acct,OU=Users,OU=Users and Groups,OU=Lausanne,OU=CH,OU=Europe",
    [String] $ou_srv_adm_acct = "OU=adm_acct,OU=Users,OU=Users and Groups,OU=Lausanne,OU=CH,OU=Europe",
    [String] $ou_std_acct = "OU=std_acct,OU=Users,OU=Users and Groups,OU=Lausanne,OU=CH,OU=Europe"
)
Function Create-User{
    Param (
        [String] $Name,
        [String] $Pass,
        [String] $Path = "OU=Users,OU=Users and Groups,OU=Lausanne,OU=CH,OU=Europe,{{ad_ldap_path_root}}"
    )

    $User = $(try {Get-ADUser $Name} catch {$null})
    If ($User -ne $Null) {
         Write-Host "User $Name already exists. Moving On."
         return $User
    } Else {
        Write-Host "Creating User $Name in $Path"
        $sec_pass = ConvertTo-SecureString $Pass -AsPlainText -Force
        return New-ADuser -Name $Name -AccountPassword $sec_pass -Path $Path -Enabled 1 -PassThru
    }
}
Function Create-Group{
    Param (
        [String] $Name,
        [String] $Path = "OU=Groups,OU=Users and Groups,OU=Lausanne,OU=CH,OU=Europe,{{ad_ldap_path_root}}"
    )

    $Group = $(try {Get-ADGroup $Name} catch {$null})
    If ($Group -ne $Null) {
        Write-Host "Group $Name already exists. Moving On."
         return $Group
    } Else {
        Write-Host "Creating Group $Name in $Path"
        return New-ADGroup -Name $Name -Path $Path -GroupScope 1 -PassThru
    }
}

#$ou_adm_acct = "OU=adm_acct,OU=Users,OU=Users and Groups,OU=Lausanne,OU=CH,OU=Europe,$OUBasePath"
#$ou_std_acct = "OU=std_acct,OU=Users,OU=Users and Groups,OU=Lausanne,OU=CH,OU=Europe,$OUBasePath"

# disabling password complexity
secedit /export /cfg C:\secpol.cfg
(Get-Content C:\secpol.cfg).replace("PasswordComplexity = 1","PasswordComplexity = 0") | Out-File C:\secpol.cfg
secedit /configure /db C:\Windows\security\local.sdb /cfg C:\secpol.cfg /areas SECURITYPOLICY
rm -force C:\secpol.cfg -confirm:$false

$userad = Create-User -Name "${username_base}ad" -Pass "$pass" -Path "${ou_adm_acct},${OUBasePath}"
$usera = Create-User -Name "${username_base}a" -Pass "$pass" -Path "${ou_srv_adm_acct},${OUBasePath}"
$user = Create-User -Name "${username_base}" -Pass "$pass" -Path "${ou_std_acct},${OUBasePath}"

$srv_adm = Create-Group -Name "$grp_srv_adm" -Path "OU=Groups,OU=Users and Groups,OU=Lausanne,OU=CH,OU=Europe,$OUBasePath"
$wks_adm = Create-Group -Name "$grp_wks_adm" -Path "OU=Groups,OU=Users and Groups,OU=Lausanne,OU=CH,OU=Europe,$OUBasePath"
$d_adm = Get-ADGroup "Domain admins"

Add-ADGroupMember -Identity $srv_adm -Members $usera
Add-ADGroupMember -Identity $wks_adm -Members $usera
Add-ADGroupMember -Identity $d_adm -Members $userad