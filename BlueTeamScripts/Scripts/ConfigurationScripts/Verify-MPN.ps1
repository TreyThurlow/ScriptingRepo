<#
.SYNOPSIS
    Performs a ping sweep and compares the results with an existing list of IPs.

.DESCRIPTION
    This script reads a list of existing IP addresses from a file, performs a ping sweep for a specified range of IP addresses,
    and compares the results to identify missing and new IP addresses. It then displays the results, highlighting unreachable known IPs and new unknown IPs.

.EXAMPLE
    # Run the script to perform a ping sweep and compare results
    .\Verify-MPN.ps1

    # Example usage:
    # The script will output the known IPs that were not reachable and the new IPs that were found during the ping sweep.
#>

# Settings the Variables
$ExistingIPs = Get-Content .\ScriptInput\FullIPList.txt
$from = 1
$to = 254

# Perfoms the ping sweep
$PingResults = $from..$to | ForEach-Object -Parallel {
    $ip = "1.1.1.$_"
    [PSCustomObject]@{
        Address = $ip
        IsReachable = Test-Connection -BufferSize 2 -TTL 5 -ComputerName $ip -Quiet -Count 1
        }
    }

# Compares the results
$MissingIPs = $ExistingIPs | Where-Object { $_ -notin $PingResults.Address}
$NewIPs = $PingResults | Where-Object {$_.Address -notin $ExistingIps}

# Displays teh results
Write-Host "The following known IPs were not able to be reached."
foreach ($MissingIP in $MissingIPs) {
    Write-Host "$MissingIP" -BackgroundColor DarkRed -ForegroundColor White
    }

Write-Host " "
Write-Host "The following IPs are not known IPs"
foreach ($NewIp in $NewIPs) {
    Write-Host "$NewIPs" -BackgroundColor Red -ForegroundColor White
    }