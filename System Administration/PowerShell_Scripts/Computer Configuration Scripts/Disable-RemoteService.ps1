<#
.SYNOPSIS
This script allows users to disable a specified service on multiple computers by either importing a list of IP addresses from a file or manually entering the IP addresses.

.DESCRIPTION
The script prompts the user to choose between importing a computer list from a file or manually typing in the IP addresses of the computers. After obtaining the list of computers, it asks for the name of the service that the user wishes to disable. It then remotely stops and disables the specified service on each of the provided computers using PowerShell remoting.

.EXAMPLE
.\Disable-RemoteService.ps1
To disable a service on a list of computers:

1. When prompted, type 'Import' to load the computer list from a file.
2. Provide the full file path containing the list of IP addresses.
3. Enter the name of the service you wish to disable.

Alternatively, you can type 'Type' to enter IP addresses manually, entering one address at a time until you press Enter without typing anything to finish.

#>

$choice = Read-Host "Do you want to import a computer list file or enter IPs? (Type 'Import' or 'Type')"

switch ($choice) {
    "Import" {
        # Get the file path from the user and read the computer list from the file
        $filePath = Read-Host "Enter the full file path of the computer list file."
        $computerList = Get-Content $filePath
    }
    "Type" {
        # Allow the user to manually enter IP addresses
        $computerList = @()
        do {
            $computer = Read-Host "Enter the IP address and press Enter."
            if ($computer -ne "") {
                $computerList += $computer
            }
        } while ($computer -ne "")
    }
    Default {
        # Handle invalid choices
        Write-Host "Invalid choice. Please choose 'Import' or 'Type'."
        Exit
    }
}

#This variable contents the name of the server that you are wanting to disable.
$ServiceName = Read-Host "Enter the Service Name that you want to disable."
#Command to disable the service
Foreach ($Computer in $Computers) {
    Invoke-Command -ComputerName $Computer -ScriptBlock {
        Get-Service -Name $ServiceName | Stop-Service -PassThru | Set-Service -StartupType Disabled
    }
}