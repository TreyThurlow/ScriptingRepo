<#
.SYNOPSIS
    Scans a remote host for files and displays their details.

.DESCRIPTION
    This script prompts the user to enter the IP address of a remote host, then uses Invoke-Command to execute a script block on the remote host.
    The script block recursively scans the C: drive of the remote host and retrieves details of all files, including their full name, creation time, 
    last access time, and last write time.

.PARAMETER IPAddress
    The IP address of the remote host to scan.

.EXAMPLE
    .\Dirwalk.ps1
    Prompts the user to enter the IP address of the remote host, scans the host, and displays the file details.
#>

# Prompt the user to enter the IP address of the host to scan
$IPAddress = Read-Host "Enter the IP Address of the host you would like to scan."

# Display the IP address and results header
Write-Host "$IPAddress Results:"
Write-Host " "

# Execute the command on the remote host to scan the C: drive and display file details
Invoke-Command -ComputerName $IPAddress -ScriptBlock {
    Get-ChildItem -Recurse C:\ | Select-Object FullName, CreationTime, LastAccessTime, LastWriteTime
} -Credential $Creds