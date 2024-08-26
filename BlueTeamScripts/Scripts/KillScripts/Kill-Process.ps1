<#
.SYNOPSIS
    Stops a process on a remote computer.

.DESCRIPTION
    This script prompts the user to enter the IP address of a remote computer and the ID of a process to stop. It then uses Invoke-Command to execute the Stop-Process cmdlet on the remote computer to stop the specified process.

.PARAMETER IPAddress
    The IP address of the remote computer.

.PARAMETER ProcessID
    The ID of the process to stop.

.EXAMPLE
    .\Kill-Process.ps1
    Prompts the user to enter the IP address of the remote computer and the ID of the process to stop, then stops the specified process on the remote computer.
#>

$IPAddress = Read-Host "Enter the IP Address of the computer that you want to disable the service on."

$ProcessID = Read-Host "Enter the ID of the process you want to stop."

Invoke-Command -ComputerName $IPAddress -ScriptBlock {Stop-Process -Id $using:ProcessID} -Credential $Creds