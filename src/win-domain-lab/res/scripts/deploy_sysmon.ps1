$legacyPathToSysmon = "C:\Windows\Sysmon.exe"
$legacySysmonName = "Sysmon.exe"
$legacySysmonPath = "C:\Windows\"

$sharedPathToSysmon = "c:\vagrant\res\conf\sysmon\"

$sysmonPath = "C:\Windows\"
$sysmonServiceName = "svcchost"
$sysmonDriverName = "svcdrv"


##
# Removes sysmon (uninstallation)
##
function UninstallSysmon ($pathToSysmon) {
    & $pathToSysmon /u
    & cmd.exe /c del /f $pathToSysmon 
}

##
# Custom hash function
##
function get-filehash2($filename) {
    $Provider = new-object System.Security.Cryptography.MD5CryptoServiceProvider
    $file = get-item -literalpath $filename
    if ($file -isnot [System.IO.FileInfo]) {
      write-error "'$($file)' is not a file."
      return
    }
    $hashstring = new-object System.Text.StringBuilder
    $stream = $file.OpenRead()
    if ($stream) {
      foreach ($byte in $Provider.ComputeHash($stream)) {

        [Void] $hashstring.Append($byte.ToString("X2"))

      }
      $stream.Close()
    }
    #"" | select-object @{Name="Path"; Expression={$file.FullName}},
    #  @{Name="$($Provider.GetType().BaseType.Name) Hash"; Expression={$hashstring.ToString()}}
    return $hashstring.ToString()
}


# Check if legagy sysmon is installed. If so, uninstall it
if (Test-Path ($legacySysmonPath + $legacySysmonName)) {
    UninstallSysmon($legacySysmonPath + $legacySysmonName)
}


## Check if sysmon binary is present on the filesystem
if (Test-Path ($sysmonPath + $sysmonServiceName + ".exe")  ) {
    # Check if sysmon is uninstalled (case when it is uninstalled but binary is still present)
    if (-Not (Get-Service $sysmonServiceName -ErrorAction SilentlyContinue)) {
        cmd.exe /c del /f ($sysmonPath + $sysmonServiceName + ".exe")
    }
    else {
        $localHash = get-filehash2($sysmonPath + $sysmonServiceName + ".exe")
        $sharedHash = get-filehash2($sharedPathToSysmon + $sysmonServiceName + ".exe")
        # Compare the local hash with the remote one, if they are not similar, we uninstall sysmon
        # in order to get the new version
        if ($localHash -ne $sharedHash){
            UninstallSysmon($sysmonPath + $sysmonServiceName + ".exe")
        }
    }
}
        
# If sysmon is uninstalled/has been uninstalled, we make sure we install it
if (-Not (Test-Path ($sysmonPath + $sysmonServiceName + ".exe"))) {
    & ($sharedPathToSysmon + $sysmonServiceName + ".exe") /accepteula /d $sysmonDriverName /i ($sharedPathToSysmon+"conf.xml") 2>&1 | Out-Null
}


