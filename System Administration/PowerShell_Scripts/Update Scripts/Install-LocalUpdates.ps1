<#
.SYNOPSIS
    Installs MSP, MSI, and MSU updates from a specified directory.

.DESCRIPTION
    This script maps a network drive to the specified update location, retrieves all MSP, MSI, and MSU updates from the directory,
    and installs them on the local machine. It uses msiexec.exe for MSP and MSI updates and wusa.exe for MSU updates.
    After the updates are installed, the script removes the mapped network drive.

.EXAMPLE
    # Run the script to install updates
    .\Install-LocalUpdates.ps1

#>

#Location of Updates

New-PSDrive -Name Y -PSProvider FileSystem -Root "Path\To\Updates"

#Variables for commands

$msiexec = 'C:\Windows\System32\msiexec.exe'
$wusa = 'C:\Windows\System32\wusa.exe'

#Create a working directory.

$UpdatePath = 'Y:\'

#Variable that contains all MSU Updates in the directory
$MSUUpdates = Get-ChildItem -Path $UpdatePath -Recurse | Where-Object {$_.Name -like "*msu*"}

#Variable that contains all MSP Updates in the directory
$MSPUpdates = Get-ChildItem -Path $UpdatePath -Recurse | Where-Object {$_.Name -like "*msp*"}

#Variable that contains all MSI Updates in the directory
$MSIUpdates = Get-ChildItem -Path $UpdatePath -Recurse | Where-Object {$_.Name -like "*msi*"}

#Installs all MSP Updates
Foreach ($MSPUpdate in $MSPUpdates) {
    $MSPUpdateFilePath = $MSPUpdate.FullName
    Write-Host "Installing MSP Update $($MSPUpdate.BaseName)" -BackgroundColor Black -ForegroundColor Green
    Start-Process -Wait $msiexec -ArgumentList "/p `"$MSPUpdateFilePath`" /qn /quiet /passive /norestart"
}

Write-Host "MSP Updates Complete" -BackgroundColor Black -ForegroundColor Yellow

#Installs all MSI Updates
Foreach ($MSIUpdate in $MSIUpdates) {
    $MSIUpdateFilePath = $MSIUpdate.FullName
    Write-Host "Installing MSI Update $($MSIUpdate.BaseName)" -BackgroundColor Black -ForegroundColor Green
    Start-Process $msiexec -ArgumentList "/i `"$MSIUpdateFilePath`" /qn /quiet /passive /norestart" -Wait
}

Write-Host "MSI Updates Complete" -BackgroundColor Black -ForegroundColor Yellow

#Installs all MSU Updates
Foreach ($MSUUpdate in $MSUUpdates) {
    $MSUUpdateFilePath = $MSUUpdate.FullName
    Write-Host "Installing MSU Update $($MSUUpdate.BaseName)" -BackgroundColor Black -ForegroundColor Green
    Start-Process $wusa -ArgumentList ($MSUUpdateFilePath, '/quiet', '/norestart') -Wait
}

Write-Host "MSU Updates Complete" -BackgroundColor Black -ForegroundColor Yellow

#Remove the PSDrive
Remove-PSDrive Y