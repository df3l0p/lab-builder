$items = Get-ChildItem "c:\vagrant\res\conf\subscriptions"
foreach ($sub in $items) {
    Write-Host "Setting $sub"
    if (wecutil.exe es | Select-String $sub.BaseName){
        Write-Host "Already setup"
        #TODO: Manage update
    }
    else {
        (wecutil.exe cs $sub.FullName) 2>&1 | Out-Null
    }
}
# The goal is to check if our SDDL exists in the list of retrieved ACLs. If it exists,
# it is most likely our ACL for wsman still exists, if not, we delete it and recreate it.
$match = $urlacls | select-string -SimpleMatch "D:(A;;GX;;;S-1-5-80-569256582-2953403351-2909559716-1301513147-412116970)(A;;GX;;;S-1-5-80-4059739203-877974739-1245631912-52717422"

# If the SDDL is not found, then we create it correctly
if (-Not ($match)){
    netsh.exe http del urlacl url=http://+:5985/wsman/
    $netshArgs = @("http", "add", "urlacl", "url=http://+:5985/wsman/", "sddl=D:(A;;GX;;;S-1-5-80-569256582-2953403351-2909559716-1301513147-412116970)(A;;GX;;;S-1-5-80-4059739203-877974739-1245631912-527174227-2996563517)(A;;GX;;;NS)")
    netsh.exe $netshArgs

    Restart-Service -name "wecsvc"
    # The following should be also done. But as with vagrant, let's to a reload in vagrant
    #Restart-Service -name "winrm"
}
