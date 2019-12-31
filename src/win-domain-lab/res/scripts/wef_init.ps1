$outCommand = wevtutil.exe el | Select-String "custom 1"
if ($outCommand) {
    Write-Host "WEF already configured. Nothing to do."
}
else {
    wecutil.exe qc -q
    wevtutil.exe sl "ForwardedEvents" /ms:53280768
}

