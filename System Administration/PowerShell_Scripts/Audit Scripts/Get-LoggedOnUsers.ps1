<#
.SYNOPSIS
    Retrieves the current logged-on users from a list of computers and exports the results to a CSV file.

.DESCRIPTION
    This script allows you to either import a list of computer names/IP addresses from a file or manually enter them.
    It then attempts to connect to each computer, retrieves the current logged-on user, and exports the results to a CSV file.
    If a computer is unreachable, it logs the status as 'No Response'.

.EXAMPLE
    # Import a list of computers from a file and retrieve logged-on users
    .\Get-LoggedOnUsers.ps1

    # Manually enter IP addresses and retrieve logged-on users
    .\Get-LoggedOnUsers.ps1
#>
# Set the Variables
$ResultDest = Read-Host "Type the full path where you would like to save the results (C:\Users\USERNAME\Documents\). ONLY THE PATH. The script will handle the filename."
$Date = Get-Date -Format "yyyy-MM-dd"
$ResultFile = $ResultDest + "CurrentLoggedOnUsers" + "_" + $Date + ".csv"
$NoResponse = "---No Response---"

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
# The Script
$Results = foreach ($Computer in $computerList)
    {
    Write-Host "Connecting to $Computer ..." -BackgroundColor Black -ForegroundColor Green
    if (Test-Connection -ComputerName $Computer -Count 1 -Quiet)
        {
        Write-Host "    System $Computer reached successfully."
        $CurrentUser = (Get-WmiObject -Class win32_ComputerSystem -ComputerName $Computer).UserName
        $IPAddressList = (([System.Net.Dns]::Resolve($Computer)).AddressList.IPAddressToString) -join ', '
        $TempObject = [PSCustomObject]@{
            MachineName = $Computer
            Status = 'Online'
            CurrentUser = $CurrentUser
            IPAddressList = $IPAddressList
            TimeStamp = (Get-Date).ToString("s")
            }
        }
        else
        {
        Write-Host "Unable to reach $Computer." -BackgroundColor Red -ForegroundColor White
        $TempObject = [PSCustomObject]@{
            MachineName = $Computer
            Status = $NoResponse
            CurrentUser = $NoResponse
            IPAddressList = $NoResponse
            TimeStamp = (Get-Date).ToString("s")
            }
        }
    $TempObject
    } 

$Results |
    Export-Csv -LiteralPath $ResultFile -NoTypeInformation