<#
.SYNOPSIS
    Scans a remote host for autorun entries and saves the results to a file.

.DESCRIPTION
    This script prompts the user to enter the IP address of a remote host, then uses Invoke-CommandAs to execute Autoruns on the remote host.
    The script retrieves autorun entries and saves the results to a text file in the user's Documents\ScriptOutput folder, with a timestamp in the file name.

.EXAMPLE
    .\Get-Autoruns.ps1
    Prompts the user to enter the IP address of the remote host, scans the host for autorun entries, and saves the results to a timestamped text file.
#>

# Prompt the user to enter the IP address of the host to scan
$IPAddress = Read-Host "Enter the IP Address of the host you would like to scan."

# Get the current date and time, formatted for use in the file name
$date = Get-Date -Format yyyy-MM-dd_hh:mm:ss

# Execute Autoruns on the remote host and store the results
$Results = Invoke-CommandAs -ComputerName $IPAddress -ScriptBlock {& "C:\Windows\system32\autorunsc64.exe" -h -accepteula -nobanner *} -AsSystem -Credential $Creds

# Save the results to a text file in the user's Documents\ScriptOutput folder
$Results | Out-File "$HOME\Documents\ScriptOutput\$IPAddress_AutoRuns_$date.txt"
