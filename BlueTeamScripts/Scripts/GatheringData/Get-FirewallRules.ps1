<#
.SYNOPSIS
    Retrieves and displays firewall rules from a remote computer.

.DESCRIPTION
    This script prompts the user to enter the IP address of a target machine, then uses Invoke-Command to execute the Get-Firewall function on the remote computer.
    The Get-Firewall function retrieves firewall rules and displays their details, including name, display name, protocol, local port, remote port, remote address, 
    enabled status, action, and direction.

.PARAMETER Target
    The IP address of the remote computer to scan.

.PARAMETER rulename
    The name of the firewall rule to retrieve.

.EXAMPLE
    .\Get-FirewallRules.ps1
    Prompts the user to enter the IP address of the target machine, retrieves the firewall rules from the remote computer, and displays their details.
#>
# Sets the Variables
$Target = Read-Host "Enter the IP address for the target machine."

# This function enables you to get all required data., Do not edit any party of this function
Function Get-Firewall
{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$rulename
        )

        Get-NetFirewallRule | Format-Table -Property Name,
        DisplayName,
        @{Name='Protocol';Expression={($PSItem | Get-NetFirewallPortFilter).Protocol}},
        @{Name='LocalPort';Expression={($PSItem | Get-NetFirewallPortFilter).LocalPort}},
        @{Name='RemotePort';Expression={($PSItem | Get-NetFirewallPortFilter).RemotePort}},
        @{Name='RemoteAddress';Expression={($PSItem | Get-NetFirewallAddressFilter).RemoteAddress}},
        Enabled,
        Action,
        Direction

}

# Performs the function against a remote computer.
Invoke-Command -ComputerName $Target -ScriptBlock ${function:Get-Firewall} -ArgumentList '*' -Credential $Creds