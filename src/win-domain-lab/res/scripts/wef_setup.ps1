$service = Get-Service winrm

$networkServiceName = (Get-WmiObject -Class win32_systemaccount -filter "SID='S-1-5-20'").Name
$eventLogReadersName = (Get-WmiObject -Class win32_group -filter "LocalAccount=True and SID='S-1-5-32-573'").Name

# Get the member of the event log readers group
$members = ([adsi]"WinNT://./$eventLogReadersName,group").psbase.Invoke('Members') | ForEach-Object {$_.GetType().InvokeMember('Name', 'GetProperty', $null, $_, $null)}

# Check if the winrm service is set properly and that network service is part of the event log reader group. 
# If not, we perform the change and restart it
if($service.ServiceType -ne "Win32OwnProcess" -or $networkServiceName -notin $members)
{
    if ($networkServiceName -notin $members){
        net localgroup $eventLogReadersName /add $networkServiceName
    } 
    sc.exe config winrm type= own
    #net stop winrm
    #net start winrm
}
gpupdate.exe /force