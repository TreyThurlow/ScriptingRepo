function Get-RegistryKeys
{
    <#
    .SYNOPSIS
        Enumerates the registry keys on a system.

    .DESCRIPTION
        This script will enumerate registry keys on a system. It is most commonly used for getting the values in the Run/RunOnce key. It can be used on a local or remote computer.

    .EXAMPLE
        Local Machine: Get-RegistryKeys -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
        Remote Machine: Invoke-Command -ComputerName $Target -Credential $Creds -ScriptBlock ${function:Get-RegistryKeys} -ArgumentList 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
    #>

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