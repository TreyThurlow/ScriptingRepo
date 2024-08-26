<#
.SYNOPSIS
    Deletes a scheduled task on a remote computer.

.DESCRIPTION
    This script prompts the user to enter the IP address of a remote computer and the name of a scheduled task to delete. It then uses PowerShell remoting to connect to the remote computer and delete the specified scheduled task without confirmation.

.EXAMPLE
    PS C:\> .\Kill-ScheduledTask.ps1
    Enter the IP Address of the computer: 192.168.1.10
    Enter the name of the Scheduled Task that you want to delete: MyTask

    This example deletes the scheduled task named 'MyTask' on the remote computer with IP address 192.168.1.10.
#>

$IPAddress = Read-Host "Enter the IP Address of the computer."

$TaskName = Read-Host "Enter the name of the Scheduled Task that you want to delete"

Invoke-Command -ComputerName $IPAddress -ScriptBlock {Unregister-ScheduledTask -TaskName $using:TaskName -Confirm:$false} -Credential $Creds