$ready=$false
while(-Not $Ready){
    Write-Host "Waiting for 10 sec"
    Start-Sleep -s 10
    try {
        get-adrootdse
        $ready=$true
        Write-Host "Domain is ready"
    }
    Catch {
        Write-Host "Not ready"
    }
}