<#
.SYNOPSIS
Retrieves and displays information about a specified firewall rule.

.DESCRIPTION
This function queries the Windows Firewall for a specific rule by its name and outputs the details in a formatted table. It provides information such as the rule's name, display name, protocol, local and remote ports, remote addresses, enablement status, action (allow or block), and direction (inbound or outbound). The user must provide the rule name as a parameter.

.PARAMETER rulename
The name of the firewall rule to retrieve information for. This parameter is mandatory.

.EXAMPLE
Get-Firewall -rulename "Allow_HTTP"
This example retrieves information about the firewall rule named "Allow_HTTP" and displays its properties in a formatted table.
#>
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