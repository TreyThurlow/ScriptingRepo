<#
.SYNOPSIS
    Scans a remote host for WMI event filters, consumers, and bindings, and displays their details.

.DESCRIPTION
    This script prompts the user to enter the IP address of a remote host, then uses Invoke-Command to execute script blocks on the remote host.
    The script retrieves and displays details of WMI event filters, event consumers, and filter-to-consumer bindings from the root\Subscription namespace.

.PARAMETER IPAddress
    The IP address of the remote host to scan.

.EXAMPLE
    .\Get-WMIEvents.ps1
    Prompts the user to enter the IP address of the remote host, scans the host for WMI event filters, consumers, and bindings, and displays their details.
#>

# Sets the Variables
$IPAddress = Read-Host "Enter the IP Address of the host you would like to scan."

# Outputs IP Results to terminal
Write-Host "$IPAddress Results:"
Write-Host " "

#Runs the command and displays the results in terminal.
Write-Host "__EventFilter Results:" -BackgroundColor Black -ForegroundColor Yellow
Write-Host " "
Invoke-Command -ComputerName $IPAddress -ScriptBlock {Get-WmiObject -Namespace root\Subscription -Class __EventFilter} -Credential $Creds

Write-Host "__EventConsumer Results:" -BackgroundColor Black -ForegroundColor Yellow
Write-Host " "

Invoke-Command -ComputerName $IPAddress -ScriptBlock {Get-WmiObject -Namespace root\Subscription -Class __EventConsumer} -Credential $Creds

Write-Host "__FilterToConsumerBinding Results:" -BackgroundColor Black -ForegroundColor Yellow
Write-Host " "

Invoke-Command -ComputerName $IPAddress -ScriptBlock {Get-WmiObject -Namespace root\Subscription -Class __FilterToConsumerBinding} -Credential $Creds
