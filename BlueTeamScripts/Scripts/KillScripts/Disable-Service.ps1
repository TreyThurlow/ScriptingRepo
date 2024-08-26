<#
.SYNOPSIS
    Disables a service on a remote computer and optionally uninstalls it.

.DESCRIPTION
    This script prompts the user to enter the IP address of a remote computer and the name of a service to disable. It then stops the specified service on the remote computer.
    The user is also prompted to decide whether to uninstall the service. If the user chooses to uninstall, the script will remove the service and delete the specified file.

.PARAMETER IPAddress
    The IP address of the remote computer.

.PARAMETER ServiceName
    The name of the service to disable.

.PARAMETER Uninstall
    A prompt asking whether to uninstall the service.

.EXAMPLE
    .\Disable-Service.ps1
    Prompts the user to enter the IP address of the remote computer and the name of the service to disable. Optionally uninstalls the service if the user chooses to do so.
#>

$IPAddress = Read-Host "Enter the IP Address of the computer that you want to disable the service on."

$ServiceName = Read-Host "Enter the name of the service you would like to disable."

$Uninstall = Read-Host "Do you also want to uninstall the service?"

Invoke-Command -ComputerName $IPAddress -ScriptBlock {Stop-Service -Name $using:ServiceName} -Credential $Creds

switch ($Uninstall)
    {
        (yes)
            {
                $FileLocation = Read-Host "Enter the full file path of the file that needs to be deleted."
                Invoke-Command -ComputerName $IPAddress -ScriptBlock {Remove-Service -Name $using:ServiceName} -Credential $Creds
                Invoke-Command -ComputerName $IPAddress -ScriptBlock {Remove-Item $using:FileLocation} -Credential $Creds
            }
        (no)
            {
                Write-Host "The service has been stopped, but is still installed."
            }
        }
