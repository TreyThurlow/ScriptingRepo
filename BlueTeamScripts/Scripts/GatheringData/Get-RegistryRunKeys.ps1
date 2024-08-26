<#
.SYNOPSIS
    Retrieves and displays registry keys from a remote computer.

.DESCRIPTION
    This script prompts the user to enter the IP address of a target machine, then uses Invoke-Command to execute the Get-RegistryKeys function on the remote computer.
    The Get-RegistryKeys function retrieves registry keys and their values from specified paths and displays them. The script specifically retrieves keys from the 
    'Run' and 'RunOnce' registry paths.

.PARAMETER Target
    The IP address of the remote computer to scan.

.PARAMETER path
    The registry path to retrieve keys from.

.EXAMPLE
    .\Get-RegistryRunKeys.ps1
    Prompts the user to enter the IP address of the target machine, retrieves the 'Run' and 'RunOnce' registry keys from the remote computer, and displays their details.
#>

# Sets the Variables
$Target = Read-Host "Enter the IP Address of the target machine."

# This function enables you to get all required data. Do not edit any part of this function.

function Get-RegistryKeys
{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$path
        )
        Push-Location
        Set-Location -Path $path
        Get-Item . | Select-Object -ExpandProperty property | ForEach-Object {
            New-Object psobject -Property @{
                "Property"=$_;
                "Value" = (Get-ItemProperty -Path . -Name $_).$_
            }
        }
        Pop-Location
    }

# Runs the command for Run Keys
Write-Host "Run Keys" -BackgroundColor Yellow -ForegroundColor Black
Invoke-Command -ComputerName $Target -Credential $Creds -ScriptBlock ${function:Get-RegistryKeys} -ArgumentList 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'

# Creates a space in the terminal
Write-Host " "

# Runs the command for RunOnce keys
Write-Host "RunOnce Keys" -BackgroundColor Yellow -ForegroundColor Black
Invoke-Command -ComputerName $Target -Credential $Creds -ScriptBlock ${function:Get-RegistryKeys} -ArgumentList 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce'