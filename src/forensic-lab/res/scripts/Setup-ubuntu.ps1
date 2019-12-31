If ((Get-AppxPackage -Name "*ubuntu*") -eq $null){
    Write-Host "Downloading Ubuntu package..."
    (New-Object System.Net.WebClient).DownloadFile("https://aka.ms/wsl-ubuntu-1604", "Ubuntu.appx")
    Write-Host "Installing Ubuntu package..."
    Add-AppxPackage -Path Ubuntu.appx
}
