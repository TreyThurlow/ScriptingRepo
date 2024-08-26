<#
.SYNOPSIS
    Retrieves and displays the actions of scheduled tasks from a specified task path.

.DESCRIPTION
    The Get-ScheduledTaskActions function retrieves scheduled tasks from the specified task path and displays their names and actions. 
    It uses the Get-ScheduledTask cmdlet to get the tasks and then iterates through each task to display its actions.

.PARAMETER TaskPath
    The path of the scheduled tasks to retrieve.

.EXAMPLE
    Get-ScheduledTaskActions -TaskPath '\'
    Retrieves and displays the actions of all scheduled tasks in the root task folder.

.EXAMPLE
    Get-ScheduledTaskActions -TaskPath '\Microsoft\Windows\TaskScheduler'
    Retrieves and displays the actions of all scheduled tasks in the 'Microsoft\Windows\TaskScheduler' folder.


#>
function Get-ScheduledTaskActions {
    param (
        [string]$TaskPath
    )

    Get-ScheduledTask -TaskPath $TaskPath | 
        Select-Object -Property TaskName, Actions |
            ForEach-Object {
                Write-Host "Task: $($_.TaskName)"
                foreach ($action in $_.Actions) {
                    Write-Host "Action: $($action.Execute)"
                    Write-Host " "
                }
            }
}