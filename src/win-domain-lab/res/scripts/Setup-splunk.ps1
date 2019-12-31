[CmdletBinding()]
param (
    [String] $version = "7.3.3",
    [String] $versionHash = "7af3758d0d5e"
)

If (-not (Test-Path "C:\Program Files\Splunk\bin\splunk.exe")) {
    Write-Host "Downloading Splunk $version"
    $msiFile = $env:Temp + "\splunk-$version-$versionHash-x64-release.msi"
    (New-Object System.Net.WebClient).DownloadFile("https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=windows&version=$version&product=splunk&filename=splunk-$version-$versionHash-x64-release.msi&wget=true", $msiFile)

    Write-Host "Installing & Starting Splunk: $msiFile"
    Start-Process -FilePath "c:\windows\system32\msiexec.exe" -ArgumentList '/i', "$msiFile", 'AGREETOLICENSE=Yes SPLUNKUSERNAME=admin SPLUNKPASSWORD=changeme /quiet' -Wait
} Else {
    Write-Host "Splunk is already installed. Moving on."
}

Write-Host "Configuring Splunk."
Copy-Item -Force -Recurse -Path C:\vagrant\res\conf\splunk\hfb\* -Destination $env:ProgramFiles\Splunk\etc\apps\

Restart-Service -Name "splunkd"

Write-Host "Splunk installation complete!"
  