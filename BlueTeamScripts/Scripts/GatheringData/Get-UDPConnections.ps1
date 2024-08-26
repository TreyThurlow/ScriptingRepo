<#
.SYNOPSIS
    Retrieves all UDP connections on a remote computer.

.DESCRIPTION
    This script uses the `Get-NetUDPEndpoint` cmdlet to retrieve all UDP connections on a computer.
    It displays the local address, local port, remote address, and remote port for each connection.

.EXAMPLE
    # Run the script to get all UDP connections
    .\Get-UDPConnections.ps1
#>

# Sets the Variables
$IPAddress = Read-Host "Enter the IP Address of the host you would like to scan."

# Outputs IP Results to terminal
Write-Host "$IPAddress Results:"
Write-Host " "

#Runs the command and displays the results in terminal.
Invoke-Command -ComputerName $IPAddress -ScriptBlock {Get-NetUDPEndpoint | Format-Table -Property LocalAddress, LocalPort, RemoteAddress, RemotePort -AutoSize} -Credential $Creds