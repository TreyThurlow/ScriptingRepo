<#
.SYNOPSIS
    Retrieves and displays scheduled tasks and their actions from a remote computer.

.DESCRIPTION
    This script prompts the user to enter the IP address of a target machine, then uses Invoke-Command to execute a script block on the remote computer.
    The script block retrieves scheduled tasks and their actions using the Get-ScheduledTask cmdlet and displays the task names and actions.

.PARAMETER Target
    The IP address of the remote computer to scan.

.EXAMPLE
    .\Get-ScheduledTasks.ps1
    Prompts the user to enter the IP address of the target machine, retrieves the scheduled tasks and their actions from the remote computer, and displays their details.
#>

# Sets the Variables
$IPAddress = Read-Host "Enter the IP Address of the host you would like to scan."

# Outputs IP Results to terminal
Write-Host "$IPAddress Results:"
Write-Host " "

#Runs the command and displays the results in terminal.

Invoke-Command -ComputerName $Target -ScriptBlock {
    Get-ScheduledTask -TaskPath \ | 
        Select-Object -Property TaskName, Actions |
            ForEach-Object {
                Write-Host "Task: $($_.TaskName)"
                foreach ($action in $_.Actions) {
                    Write-Host "Action: $($action.Execute)"
                    Write-Host " "
                    }
                }
            } -Credential $Creds
        