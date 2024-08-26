<#
.SYNOPSIS
    Stops an injected thread on a remote computer.

.DESCRIPTION
    This script prompts the user to enter the IP address of a remote computer and the TID (Thread ID) of an injected thread. It then uses PowerShell remoting to connect to the remote computer and stop the specified thread using the Stop-Thread command.

.EXAMPLE
    PS C:\> .\Stop-RemoteThread.ps1
    Enter the IP Address of the computer: 192.168.1.10
    Enter the TID of the injected thread: 1234

    This example stops the injected thread with TID 1234 on the remote computer with IP address 192.168.1.10.
#>

$IPAddress = Read-Host "Enter the IP Address of the computer."

$TID = Read-Host "Enter the TID of the injected thread."

# Runs the Stop-Thread command on the remote computer
Invoke-CommandAs -ComputerName $IPAddress -Scriptblock {Stop-Thread -ThreadId $using:TID} -AsSystem -Credential $Creds