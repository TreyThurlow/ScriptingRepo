<#
.SYNOPSIS
    Connects to remote computers, copies configuration files, and executes commands.

.DESCRIPTION
    This script connects to a list of remote computers using PowerShell sessions, copies various configuration files and scripts to the remote computers, 
    executes specific commands such as activating Sysmon configurations, and finally removes the sessions. It handles tasks like copying Sysmon configuration files, 
    activating Sysmon, copying PowerShell modules, and copying Autoruns.

.EXAMPLE
    .\SetUp.ps1
    Connects to the specified computers, copies the necessary files, executes the commands, and removes the sessions.
#>
#Sets variables and connects to computers
$computers = @("ip1","ip2")
$pso = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
Foreach ($computer in $computers) { 
    New-PSSession -ComputerName $computer -SessionOption $pso -Credential $creds }

# Stores all open sessions into a variable
$sessions = Get-PSSession

# Copies the sysmon config file to remote computers
foreach ($session in $sessions) {
    Copy-Item ".\PushItems\sysmonconfig-MDT.xml" -Destination C:\systemonconfig-MDT.xml -ToSession $session
    }

# Activates the sysmon config file.
foreach ($session in $sessions) {
    Invoke-Command -Session $session -ScriptBlock {& "C:\Program Files\Sysmon\sysmon64.exe" -c C:\sysmonconfig-MDT.xml}
    }

# Removes the sysmon config file.
Foreach ($session in $sessions) {
    Invoke-Command -Session $session -ScriptBlock {Remove-Item C:\sysmonconfig-MDT.xml}
}

Foreach ($session in $sessions) {
    Invoke-Command -Session $session -ScriptBlock {New-Item -ItemType Directory "C:\Program Files\WindowsPowerShell\Modules\Get-InjectedThread"
    Copy-Item ".\PushItems\Get-InjectedThread.ps1" -Destination "C:\Program Files\WindowsPowerShell\Modules\Get-InjectedThread\Get-InjectedThread.ps1" -ToSession $session
        }
    }

Foreach ($session in $sessions) {
    Invoke-Command -Session $session -ScriptBlock {New-Item -ItemType Directory "C:\Program Files\WindowsPowerShell\Modules\Stop-InjectedThread"
    Copy-Item ".\PushItems\Get-InjectedThread.ps1" -Destination "C:\Program Files\WindowsPowerShell\Modules\Stop-InjectedThread\Stop-InjectedThread.psm1" -ToSession $session
        }
    }

# Copies Autoruns to the MPN
Foreach ($session in $sessions) {
    Copy-Item ".\PushItems\autorunsc64.exe" -Destination "C:\Windows\system32\autorunsc64.exe" -ToSession $session
}

# Removes the sessions
Remove-PSSession $sessions