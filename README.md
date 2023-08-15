# reInstallSCCM.ps1

## Action - Manual re-installation of SCCM agent

## Purpose
There is an off chances you are unable to re-install the client from the SCCM console you must be able to login and fix the issue at hand.  This script handles the following items:
* Function showing a spinning star showing process
* A function to remove sccm from the affected device
* Debug switch to help you ID any issues with the script
* Connectivity test
* Two statements for install sccm agent

## 2012+ clients
When you use this script you need to use the -Version switch to set it to 10.  10 represents "Windows 10" and in this catagory I have lumbed in the following OS's:
* Windows server (12, 12R2, 2016, 2019, 2022)
* Windows 10 / 11

## 2008 / 2008R2 / Win 7
While these clients are technically not supported.  If you have the correct agent you can use this  script to point to the correct file location and it will install it.  You can set -Version to anything you want but "10" and it will activate the else statement.

## Configurating
This script comes with several parameters that will need to be set in order to work correctly.  I will list those below.  They are line item 9 of the script.

### WMI cleanup script
If you don't want to use the WMI clean up script simply comment out line 97.

### Custom settings
$path = "Path of install files"</br>

$smsSite = "SiteCode"

$sccmHost = "SCCM host the client needs to talk to"

$xmlURL = "xml configuration url"

## How this works
Basically, if you fill out the powershell script correctly.  You have are logged in  with a user that has permissions to the install files.  The script will reach out and download the files and store them in c:\Temp\<FolderName>.  It will then kick off the uninstall process do a series of cleanup and clean WMI for you.  Place the "sccmWMIFix.bat" in the install folder.  Once it has removed the agent it will begin re-installing the agent.

## Do not deploy this via SCCM.
It will fail and produce zero results.  Don't say I didn't warn you.

## Netskip switch
Sometimes things go bad.  Communications are not entirely blocked but ping may not work.  In this case just set the -netskip 1 and it will bypass the check and move on with the install.  Only use this if you know the agent can talk to sccm but the check fails anyways.
