<#
.SYNOPSIS
    Removes a specified registry key from the Run or RunOnce hive on a remote computer.

.DESCRIPTION
    This script prompts the user to enter the IP address of a remote computer, the hive location (Run or RunOnce), and the name of the registry key to be removed. It then removes the specified registry key from the appropriate hive on the remote computer using PowerShell remoting.

.EXAMPLE
    PS C:\> .\Remove-RegistryKey.ps1
    Enter the IP Address of the computer that you want to disable the service on: 192.168.1.10
    Is it in the Run or RunOnce Hive? Run
    Enter the name of the property you would like to remove: MyApp

    This example removes the 'MyApp' registry key from the Run hive on the remote computer with IP address 192.168.1.10.
#>

$IPAddress = Read-Host "Enter the IP Address of the computer that you want to disable the service on."

$Location = Read-Host "Is it in the Run or RunOnce Hive?"

$Regkey = Read-Host "Enter the name of the property you would like to remove."

switch ($Location) {
    "Run" {
        $path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\"
        $keypath = $path + $Regkey
        Invoke-Command -ComputerName $IPAddress -ScriptBlock {Remove-ItemProperty $keypath -Force} -Credential $Creds
    }
    "RunOnce" {
        $path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce\"
        $keypath = $path + $Regkey
        Invoke-Command -ComputerName $IPAddress -ScriptBlock {Remove-ItemProperty $keypath -Force} -Credential $Creds
    }
}