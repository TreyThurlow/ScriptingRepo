<#
.SYNOPSIS
    Deletes a local user account on a remote computer.

.DESCRIPTION
    This script prompts the user to enter the IP address of a remote computer and the username of a local user account to delete. It then uses PowerShell remoting to connect to the remote computer and delete the specified user account.

.EXAMPLE
    PS C:\> .\Kill-User.ps1
    Enter the IP Address of the computer: 192.168.1.10
    Enter the username of the user that you want to delete: JohnDoe

    This example deletes the local user account named 'JohnDoe' on the remote computer with IP address 192.168.1.10.
#>

$IPAddress = Read-host "Enter the IP Address of the computer."

$Username = "Enter the username of the user that you want to delete."

Invoke-Command -ComputerName $IPAddress -ScriptBlock {Remove-LocalUser -Name $using:Username} -Credential $Creds