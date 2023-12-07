# Purpose: SCCM client install (SCCM script)
# Date: 07/28/2023

Param(	$version, 
		$netSkip = $false, 
		$debug = $false
)

# Custom settings
$path = 
$smsSite = 
$sccmHost = 
$xmlURL =

 # Variables$removeClient = $false
$folder = $path -split "\\"
$folder = $folder[$folder.count -1]
$localPath = "C:\Temp\$folder"
$installClient = $false
$removeClient = $false

#-------------------------------- Functions -----------------------------------------
# Display animated status function
function displayStatus {
	param(
		[Parameter(Mandatory = $true)] $message,
		[Parameter(Mandatory = $true)] $processName
	)
    $star = @("/", "|", "\", "-")
	$i = 0
	$startPos = $HOST.UI.RawUI.CursorPosition
    
	While ($true) {		
		Write-Host -nonewline $message $star[$i]
		Start-Sleep -milliseconds 50
		$HOST.UI.RawUI.CursorPosition = $startPos
		$i++
		if ($i -eq 4) { $i = 0 }
		if (-not (Get-Process -Name $processName -ErrorAction SilentlyContinue)) { break }
	}
}

#------------------------------- Copy Funtion ---------------------------------------

function copyFiles {
    param($lPath, $rPath)

    # Test to see if the files on are on computer
    $copyTst = Test-Path $lPath

    if ($copyTst) { 
        $a = Get-ChildItem -Recurse -Path $rPath
        $b = Get-ChildItem -Recurse -Path $lPath
        $c = Compare-Object -ReferenceObject $a -DifferenceObject $b

        # Copy over the WMI fix
        if (!Test-Path -Path "$lPath\sccmWMIFix.bat") {
			xcopy $rPath\sccmWMIFix.bat $lPath /e /i
		}
    }

    # start fresh copy
    #if (!$copyTst) { Start-Process -FilePath "xcopy" -ArgumentList "$rPath $lPath /e /i" -Wait }
    Start-Process -FilePath "xcopy" -ArgumentList "$var1 $var2 /e /i" -Wait
}

#------------------------------- Remove Function ---------------------------------------

# Remove function
function removeSCCM {
	param($var1, $var2)
	
	# Run cleanup process (ccmclean)
	Start-Process -FilePath "$var2\ccmclean.exe" -ArgumentList "/q" -Wait
	displayStatus -message "UnInstalling!  " -processName "ccmclean"

	# Remove old folders (ccmsetup & ccm)
	Get-ChildItem C:\Windows\CCM | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
	Remove-Item C:\Windows\CCM-Install -Recurse -Force -ErrorAction SilentlyContinue
	Remove-Item C:\Windows\ccmcache -Recurse -Force -ErrorAction SilentlyContinue
	Remove-Item C:\Windows\ccmsetup -Recurse -ErrorAction SilentlyContinue

	# Remove old cert keys in registery
	Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\SystemCertificates\SMS\Certificates -Recurse -ErrorAction SilentlyContinue | Remove-Item
}
#-------------------------------- Functions end --------------------------------------

# Debug folder pathes
if ($debug) {
	Write-Output "Remote Path: $path"
	Write-Output "Folder: $folder"
	Write-Output "Local folder: $localPath"
}

# Connectivity test
if (!$netSkip) {
	$ping = Test-Connection $sccmHost -Quiet
    $sccmXML = Invoke-Webrequest $xmlURL -DisableKeepAlive -ErrorAction SilentlyContinue
	
	if ($ping -eq $true -and $sccmXML.StatusCode -eq 200) { $removeClient = $true }
	else { if ($debug) { Write-Output "Connectivity Test failed!"} }
	
}
elseif ($netSkip -eq $true -and $version -ne $null) { $removeClient = $true }

# Copy Files
copyFiles -localPath $localPath -rPath $path

# Debug items.
if ($debug) { Write-Output "Remove client state: $removeClient" }
if ($debug) { Write-Output "OS version: $version" }

# Remove SCCM
if ($removeClient) { 
	removeSCCM -var1 $path -var2 $localPath	

	# Run WMI Fix
	Start-Process -FilePath "$localPath\sccmWMIFix.bat" -Wait
	$installClient = $true
}
	
#Re-install the client
if ($installClient) {
	if ($verion -eq 10) { Start-Process -FilePath $Exe -WorkingDirectory "$localPath" }
	else { Start-Process -FilePath "ccmsetup.exe" -WorkingDirectory "$localPath" -ArgumentList "/source:$localPath\ccmsetup", $smsSite }

	# Display install status.
	displayStatus -message "Installing!  " -processName "ccmsetup"
} 
