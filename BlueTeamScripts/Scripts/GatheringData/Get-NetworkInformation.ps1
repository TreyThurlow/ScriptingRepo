<#
.SYNOPSIS
    Scans a remote host for network adapters and displays their details.

.DESCRIPTION
    This script prompts the user to enter the IP address of a remote host, then uses Invoke-Command to execute a script block on the remote host.
    The script block retrieves details of network adapters using the Get-NetAdapter cmdlet and displays them.

.PARAMETER IPAddress
    The IP address of the remote host to scan.

.EXAMPLE
    .\Get-NetworkInformation.ps1
    Prompts the user to enter the IP address of the remote host, scans the host for network adapters, and displays their details.
#>

# Prompt the user to enter the IP address of the host to scan
$IPAddress = Read-Host "Enter the IP Address of the host you would like to scan."

# Display the IP address and results header
Write-Host "$IPAddress Results:"
Write-Host " "

# Execute the command on the remote host to retrieve network adapter details
Invoke-Command -ComputerName $IPAddress -ScriptBlock {
    Get-NetAdapter
} -Credential $Creds