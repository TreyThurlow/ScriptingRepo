<#
.SYNOPSIS
    Scans a remote host for Windows services and displays their details.

.DESCRIPTION
    This script prompts the user to enter the IP address of a remote host, then uses Invoke-Command to execute a script block on the remote host.
    The script block retrieves details of Windows services using the Get-WmiObject cmdlet and displays them, including state, name, display name, process ID, path name, and start mode.

.PARAMETER IPAddress
    The IP address of the remote host to scan.

.EXAMPLE
    .\Get-Services.ps1
    Prompts the user to enter the IP address of the remote host, scans the host for Windows services, and displays their details.
#>

# Sets the Variables
$IPAddress = Read-Host "Enter the IP Address of the host you would like to scan."

# Outputs IP Results to terminal
Write-Host "$IPAddress Results:"
Write-Host " "

#Runs the command and displays the results in terminal.
Invoke-Command -ComputerName $IPAddress -ScriptBlock {
    Get-WmiObject -Class Win32_Service | Sort-Object -Property State, Name | Select-Object State, Name, DisplayName, PathName, StartMode
} -Credential $Creds