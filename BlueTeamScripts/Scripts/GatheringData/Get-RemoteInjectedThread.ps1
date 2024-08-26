<#
.SYNOPSIS
    Scans a specified host for injected threads using the Get-InjectedThread module.

.DESCRIPTION
    This script prompts the user to enter the IP address of a host they would like to scan for injected threads.
    It then runs the Get-InjectedThread script on the specified host and displays the results in the terminal.

.EXAMPLE
    # Run the script to scan a host for injected threads
    .\Get-RemoteInjectedThreads.ps1

    # Example usage:
    # Enter the IP Address of the host you would like to scan: 192.168.1.100
    # The script will output the results of the Get-InjectedThread scan for the specified host.
#>

# Sets the Variables
$IPAddress = Read-Host "Enter the IP Address of the host you would like to scan."

# Outputs IP Results to terminal
Write-Host "$IPAddress Results:"
Write-Host " "

#Runs the command and displays the results in terminal.
Invoke-CommandAs -ComputerName $IPAddress -ScriptBlock {& "C:\Program Files\WindowsPowerShell\Modules\Get-InjectedThread\Get-InjectedThread.ps1"} -AsSystem -Credential $Creds