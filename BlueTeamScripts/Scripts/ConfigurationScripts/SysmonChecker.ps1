<#
.SYNOPSIS
    Checks and resolves the status of Sysmon and WinLogBeats services on multiple computers.

.DESCRIPTION
    This script reads a list of computer IPs from a file, establishes PowerShell sessions to each computer, and checks if Sysmon and WinLogBeats services are running.
    It also verifies the Sysmon configuration file against a known good configuration. If any issues are found, the script attempts to resolve them by starting services or updating configurations.

.EXAMPLE
    # Run the script to check and resolve Sysmon and WinLogBeats status
    .\SysmonCecker.ps1

    # Example usage:
    # Enter credentials when prompted
    # The script will output the status of Sysmon and WinLogBeats for each computer and attempt to resolve any issues found
#>

#SCRIPT IS UNTESTED

# Setting the Variables
$computers = Get-Content .\ScriptInput\IPList.txt
$pso = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
$sysmon = "sysmon"
$winlogbeat = "winlogbeat"


Foreach ($computer in $computers) { 
    New-PSSession -ComputerName $computer -SessionOption $pso -Credential $creds 
}

$Sessions = Get-PSSession

# WinLogBeats ScriptBlock
$WinLogBeatScriptBlock = {
    if (Get-Service -Name $using:winlogbeat -ErrorAction SilentlyContinue) {
        # WinLogBeats is running
        Write-Host "$env:COMPUTENAME: WinLogBeats is running." -BackgroundColor Green -ForegroundColor Black
        $true
        } else { 
            # WinLogBeats is not running
            Write-Host "$env:COMPUTERNAME: WinLogBeats is not running."
            $false
            }
        }

# Make a variable to store results
$ComputersNotRunningWinLogBeats = @()

# Iterate through each computer and invoke the WinLogBeats scriptblock
foreach ($session in $sessions) {
    $WinLogResults = Invoke-Command -Session $Session -ScriptBlock $WinLogBeatScriptBlock -Credential $creds
    if (-not $WinLogResults) {
        $computersNotRunningWinLogBeats += $computer
        }
    }

#SysmonScriptBlock
$SysmonScriptBlock = {
    if (Get-Process -Name $using:sysmon -ErrorAction SilentlyContinue) {
        # Sysmon is running
        Write-Host "$env:COMPUTENAME: Sysmon is running." -BackgroundColor Green -ForegroundColor Black
        $true
        } else { 
            # Sysmon is not running
            Write-Host "$env:COMPUTERNAME: Sysmon is not running."
            $false
            }
        }

# Iterate through each computer and invoke the sysmon scriptblock
foreach ($session in $sessions) {
    $SysmonResults = Invoke-Command -Session $Session -ScriptBlock $SysmonScriptBlock -Credential $creds
    if (-not $SysmonResults) {
        $computersNotRunningSysmon += $computer
        }
    }
# Sysmon Config
$ComputersNeedingSysmonConfig = @()

# Gets the hash from the remote computer's sysmon running config and compares it to the sysmon config file that was pushed.
foreach ($session in $sessions) {
    Invoke-Command -Session $session -ScriptBlock {& 'C:\Program Files\sysmon\sysmon.exe' -c} -Credential $creds > .\ScriptInput\$computer-sysmonconfig.txt

    $sysconfig = (Get-Content -Path .\ScriptInput\$computer-sysmonconfig.txt) | ForEach-Object { if ($_ -match "SHA256=") { $_.Split("=")[1].Trim() } }
    $originalconfig = Get-FileHash .\PushItems\sysmonconfig-MDT.xml -Algorithm SHA256 | Select-Object -ExpandProperty Hash

    if ($sysconfig -like $originalconfig) {
        Write-Host "Sysmon Config are correct for $computer" -BackgroundColor Green -ForegroundColor Black
        } else {
            Write-Host "Sysmon Configs have been modified for $computer" -BackgroundColor Red -ForegroundColor White
            $ComputersNeedingSysmonConfig += $computer
            }
        }

# Lists the computers not running WinLogBeats

if ($null -ne $ComputersNotRunningWinLogBeats) {
    Write-Host "The following computers do not have the WinLogBeats service running:
    $ComputersNotRunningWinLogBeats" -ForegroundColor White -BackgroundColor Red
    }

# Lists the computers not running Sysmon

if ($null -ne $ComputersNotRunningSysmon) {
    Write-Host "The following computers do not have the Sysmon service running:
    $ComputersNotRunningSysmon" -ForegroundColor White -BackgroundColor Red
    }

# Lists the computers that had the config file modified

if ($null -ne $ComputersNeedingSysmonConfig) {
    Write-Host "The following computers had a modification to the sysmon config file:
    $ComputersNotRunningSysmon" -ForegroundColor White -BackgroundColor Red
    }

# Below foreach loops resolves all issues.
Foreach ($comp in $ComputersNotRunningSysmon) {
    Copy-Item -Path .\PushItems\sysmonconfig-MDT.xml -Destination \\$sys\c$\sysmonconfig-MDT.xml -Credential $creds
    Invoke-Command -ComputerName $sys -ScriptBlock {& 'C:\Program Files\sysmon\sysmon64.exe' -c C:\sysmonconfig-MDT.xml} -Credential $creds
    }

Foreach ($sys in $ComputersNeedingSysmonConfig) {
    Copy-Item -Path .\PushItems\sysmonconfig-MDT.xml -Destination \\$sys\c$\sysmonconfig-MDT.xml -Credential $creds
    Invoke-Command -ComputerName $sys -ScriptBlock {& 'C:\Program Files\sysmon\sysmon64.exe' -c C:\sysmonconfig-MDT.xml} -Credential $creds
    Invoke-Command -ComputerName $sys -ScriptBlock {Remove-Item C:\sysmonconfig-MDT.xml} -Credential $creds
    }

Foreach ($system in $ComputersNotRunningWinLogBeats) {
    Invoke-Command -ComputerName $system -ScriptBlock {Start-Service $using:winlogbeats} -Credential $creds
    }