<#
.SYNOPSIS
    Scans a remote host for TCP connections and displays their details.

.DESCRIPTION
    This script prompts the user to enter the IP address of a remote host, then uses Invoke-Command to execute a script block on the remote host.
    The script block retrieves details of TCP connections using the Get-NetTCPConnection cmdlet and displays them.

.PARAMETER IPAddress
    The IP address of the remote host to scan.

.EXAMPLE
    .\Get-TCPConnections.ps1
    Prompts the user to enter the IP address of the remote host, scans the host for TCP connections, and displays their details.
#>

# Sets the Variables
$IPAddress = Read-Host "Enter the IP Address of the host you would like to scan."

# Outputs IP Results to terminal
Write-Host "$IPAddress Results:"
Write-Host " "

#Runs the command and displays the results in terminal.
Invoke-Command -ComputerName $IPAddress -ScriptBlock {Get-NetTCPConnection} -Credential $Creds