<#
.SYNOPSIS
    Scans a remote host for local users and displays their details.

.DESCRIPTION
    This script prompts the user to enter the IP address of a remote host, then uses Invoke-Command to execute a script block on the remote host.
    The script block retrieves details of local users, including their name, SID, enabled status, and description, and displays them.

.PARAMETER IPAddress
    The IP address of the remote host to scan.

.EXAMPLE
    .\Get-LocalUsers.ps1
    Prompts the user to enter the IP address of the remote host, scans the host for local users, and displays their details.
#>
# Sets the Variables
$IPAddress = Read-Host "Enter the IP Address of the host you would like to scan."

# Outputs IP Results to terminal
Write-Host "$IPAddress Results:"
Write-Host " "

#Runs the command and displays the results in terminal.
Invoke-Command -ComputerName $IPAddress -ScriptBlock {Get-LocalUser -Name * | Select-Object Name, SID, Enabled, Description} -Credential $Creds