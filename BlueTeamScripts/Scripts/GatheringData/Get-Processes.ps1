<#
.SYNOPSIS
    Scans a remote host for running processes and displays their details.

.DESCRIPTION
    This script prompts the user to enter the IP address of a remote host, then uses Invoke-Command to execute a script block on the remote host.
    The script block retrieves details of running processes using the Get-WMIObject cmdlet and displays them in a formatted table.

.PARAMETER IPAddress
    The IP address of the remote host to scan.

.EXAMPLE
    .\Get-Processes.ps1
    Prompts the user to enter the IP address of the remote host, scans the host for running processes, and displays their details in a formatted table.
#>

# Prompt the user to enter the IP address of the host to scan
$IPAddress = Read-Host "Enter the IP Address of the host you would like to scan."

# Display the IP address and results header
Write-Host "$IPAddress Results:"
Write-Host " "

# Execute the command on the remote host to retrieve running process details
Invoke-Command -ComputerName $IPAddress -ScriptBlock {
    Get-WMIObject win32_Process | Select-Object Name, ProcessId, ParentProcessId, ExecutablePath, CreationDate | Format-Table -Autosize
} -Credential $Creds