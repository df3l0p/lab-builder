$items = Get-ChildItem "c:\vagrant\res\conf\GPO" | Sort-Object
foreach ($gpo_dir in $items) {
    Write-Host "Configuring $gpo_dir"
    Import-GPO -BackupGpoName $gpo_dir -Path $gpo_dir.FullName -TargetName $gpo_dir -CreateIfNeeded
    $lines = Get-Content -Path $($gpo_dir.FullName + "/gpo_links.txt")
    ForEach ($OU in $lines){
        Write-Host "OU: $OU"
        $gpLinks = $null
        $gPLinks = Get-ADOrganizationalUnit -Identity $OU -Properties name,distinguishedName, gPLink, gPOptions
        $gpo = Get-GPO $gpo_dir
        If ($gPLinks.LinkedGroupPolicyObjects -notcontains $gpo.path){
            New-GPLink -Name $gpo_dir -Target $OU -Enforced yes
        }
        else {
            Write-Host "GpLink $gpo_dir already linked on $OU. Moving On."
        }
    }
}