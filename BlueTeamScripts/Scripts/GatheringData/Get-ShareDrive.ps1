<#
.SYNOPSIS
    Scans a remote host for network drives, SMB shares, and connected named SMB pipes.

.DESCRIPTION
    This script prompts the user to enter the IP address of a remote host, then uses Invoke-Command to execute script blocks on the remote host.
    The script retrieves and displays details of mapped network drives, network SMB shares, and connected named SMB pipes.

.PARAMETER IPAddress
    The IP address of the remote host to scan.

.EXAMPLE
    .\Get-ShareDrive.ps1
    Prompts the user to enter the IP address of the remote host, scans the host for network drives, SMB shares, and connected named SMB pipes, and displays their details.
#>
# Sets the Variables
$IPAddress = Read-Host "Enter the IP Address of the host you would like to scan."

# Outputs IP Results to terminal
Write-Host "$IPAddress Results:"
Write-Host " "

#Runs the command and displays the results in terminal.
Write-Host "Mapped Network Drives:" -ForegroundColor Yellow -BackgroundColor Black
Invoke-Command -ComputerName $IPAddress -ScriptBlock {Get-PSDrive} -Credential $Creds

Write-Host " "
Write-Host "Network SMB Shares " -ForegroundColor Yellow -BackgroundColor Black

Invoke-Command -ComputerName $IPAddress -ScriptBlock {Get-SmbShare} -Credential $Creds

Write-Host " "
Write-Host "Connected Named SMB Pipes" -ForegroundColor Yellow -BackgroundColor Black

Invoke-Command -ComputerName $IPAddress -ScriptBlock {(get-childitem \\.\pipe\).FullName} -Credential $Creds