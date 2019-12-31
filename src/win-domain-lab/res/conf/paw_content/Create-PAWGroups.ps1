# Create-PAWGroups.ps1

$countryOU = "OU=CH,OU=Europe," 
$prefixOUName = "CH - "
$prefixOUSamAccountName = "ch_"


$csvGroups = @"
Name,samAccountName,GroupCategory,GroupScope,DisplayName,OU,Description,Membership
${prefixOUName}Tier 0 Replication Maintenance,${prefixOUSamAccountName}Tier0ReplicationMaintenance,Security,Global,${prefixOUName}Tier 0 Replication Maintenance,"OU=Groups,OU=Tier 0,OU=Admin",Members of this group are Tier 0 Replication Maintenance,
${prefixOUName}Tier 1 Server Maintenance,${prefixOUSamAccountName}Tier1ServerMaintenance,Security,Global,${prefixOUName}Tier 1 Server Maintenance,"OU=Groups,OU=Tier 1,OU=Admin",Members of this group perform Tier 1 Server Maintenance,
${prefixOUName}Service Desk Operators,${prefixOUSamAccountName}ServiceDeskOperators,Security,Global,${prefixOUName}Service Desk Operators,"OU=Groups,OU=Tier 2,OU=Admin",Members of this group are Service Desk Operators,
${prefixOUName}Workstation Maintenance,${prefixOUSamAccountName}WorkstationMaintenance,Security,Global,${prefixOUName}Workstation Maintenance,"OU=Groups,OU=Tier 2,OU=Admin",Members of this group perform Workstation Maintenance,
${prefixOUName}Cloud Service Admins,${prefixOUSamAccountName}cloudadmins,Security,Global,${prefixOUName}Cloud Service Admins,"OU=Groups,OU=Tier 0,OU=Admin",Members of this group are permitted to connect to pre-identified cloud services via Privileged Access Workstations,
${prefixOUName}PAW Users,${prefixOUSamAccountName}pawusers,Security,Global,${prefixOUName}PAW Users,"OU=Groups,OU=Tier 0,OU=Admin",Members of this group are permitted to log onto Privileged Access Workstations,
${prefixOUName}PAW Maintenance,${prefixOUSamAccountName}pawmaint,Security,Global,${prefixOUName}PAW Maintenance,"OU=Groups,OU=Tier 0,OU=Admin",Members of this group maintain and support Privileged Access Workstations,
${prefixOUName}Tier 1 Admins,${prefixOUSamAccountName}tier1admins,Security,Global,${prefixOUName}Tier 1 Admins,"OU=Groups,OU=Tier 1,OU=Admin",Members of this group are Tier 1 Administrators,
${prefixOUName}Tier 2 Admins,${prefixOUSamAccountName}tier2admins,Security,Global,${prefixOUName}Tier 2 Admins,"OU=Groups,OU=Tier 2,OU=Admin",Members of this group are Tier 2 Administrators,
"@

#Include PS Environment
#. ..\..\Scripts\Custom\PSEnvironment.ps1
. .\\ADEnvironment.ps1

#Configure Local Variables
$sSourceDir = Get-Location
# Uncomment the following line and comment the line after if you
# want to keep the default hierarchy provided by microsoft
#$rootDSE = (Get-ADRootDSE).defaultNamingContext
$rootDSE = $countryOU + (Get-ADRootDSE).defaultNamingContext

#$Groups = Import-Csv $sSourceDir"\Groups.csv"
$Groups = ConvertFrom-Csv $csvGroups
foreach ($Group in $Groups){
    $groupName = $Group.Name
    $groupOUPrefix = $Group.OU
    $destOU = $Group.OU + "," + $rootDSE
    $groupDN = "CN=" + $groupName + "," + $destOU
    #$groupDN = $Group.OU + "," + $rootDSE
    # Check if the target group already is present.
    $checkForGroup = Test-XADGroupObject $groupDN
    If (!$checkForGroup)
    {
        # The group is not present, creating group.
        Write-Host "Creating the group " + $Group.Name + " in " + $groupDN
        New-ADGroup -Name $Group.Name -SamAccountName $Group.samAccountName -GroupCategory $Group.GroupCategory -GroupScope $Group.GroupScope -DisplayName $Group.DisplayName -Path $destOU -Description $Group.Description

        If ($Group.membership -and $Group.Membership -ne ""){
#            Add-Log -LogEntry("Adding " + $Group.Name + " to " + $Group.Membership);
            Add-ADPrincipalGroupMembership -Identity $Group.samAccountName -MemberOf $Group.Membership;
        }
        $error.Clear()
    } 
    Else
    {
        # The group is present, log a message.
#        Add-Log -LogEntry("The group name " + $Group.Name + " already exists in the " + $destOU + " OU.")        
    }
}    

