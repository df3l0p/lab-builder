# Remove OneDrive from the System
Write-Host "Removing OneDrive..."
$onedrive = Get-Process onedrive -ErrorAction SilentlyContinue
if ($onedrive) {
  taskkill /f /im OneDrive.exe
}
c:\Windows\SysWOW64\OneDriveSetup.exe /uninstall

# Disabling Windows defender
Write-Host "Disabling Windows Defender..."
Set-MpPreference -DisableRealtimeMonitoring $true