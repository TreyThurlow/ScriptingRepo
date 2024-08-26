<#
.SYNOPSIS
    Changes the Primary and Secondary DNS Servers on all specified clients.

.DESCRIPTION
    This script reads a list of computer names from a specified file, updates the DNS server addresses for each computer, 
    and displays the DNS server addresses before and after the update.

.EXAMPLE
    .\Change-DNSServers.ps1
    Prompts for the IP addresses of the new DNS servers and updates the DNS settings on the computers listed in the specified file.
#>

#Variable containing Computer List based on location and computer type.

$Computers = Get-Content Path\To\File

#This variable stores the IP Addresses that you enter for the DNS servers.
$NewDNSServerSearchOrder = Read-Host "Type the IP Addresses of the two new DNS Servers with a comma and space separating them (1.1.1.1, 2.2.2.2)"

#Begins the commands per computer
Foreach ($Computer in $Computers) {
    Write-Host "$($Computer): " -ForegroundColor Yellow
    Invoke-Command -ComputerName $Computer -ScriptBlock {

        $Adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {$_.DHCPEnabled -ne 'True' -and $_.DNSServerSearchOrder -ne $null}

        #Show DNS Servers before Update
        Write-Host "Before: " -ForegroundColor Green
        $Adapters | Foreach-Object {$_.DNSServerSearchOrder}

        #Update DNS Servers
        $Adapters | Set-DnsClientServerAddress -ServerAddresses $NewDNSServerSearchOrder

        #Show DNS Servers after Update
        $Adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {$_.DHCPEnabled -ne 'True' -and $_.DNSServerSearchOrder -ne $null}
        Write-Host "After: " -ForegroundColor Cyan
        $Adapters | Foreach-Object {$_.DNSServerSearchOrder}
    }
}