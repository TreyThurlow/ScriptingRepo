<#
.SYNOPSIS
    Gathers system information from a Linux machine in one SSH session.

.DESCRIPTION
    This script connects to a specified Linux machine via SSH and collects various system information, including file directory details, local groups and users, installed software, firewall rules, networking data, cron jobs, current network connections, and running processes. The information is saved to a specified output directory.

.EXAMPLE
    PS C:\> .\Get-LinuxBaseline.ps1
    Enter an IP address or press Enter to finish: 192.168.1.20
    Enter an IP address or press Enter to finish: 

    This example gathers system information from the Linux machine with IP address 192.168.1.20 and saves it to the default output directory.
#>

# Function to gather system information from a Linux machine in one SSH session
function Get-LinuxSystemInfo {
    param (
        [string]$ip,
        [string]$outputDir
    )

    $sshCommand = @"
ssh user@$ip << 'EOF'
echo "Gathering information from $ip..."

# Full file directory information
ls -alR / > $outputDir/file_directory_info.txt

# Local groups and users
cat /etc/group > $outputDir/local_groups.txt
cat /etc/passwd > $outputDir/local_users.txt

# Installed software
dpkg -l > $outputDir/installed_software.txt

# Firewall rules
sudo iptables -L > $outputDir/firewall_rules.txt

# Networking data
ifconfig > $outputDir/networking_data.txt

# Cron jobs
crontab -l > $outputDir/cron_jobs.txt

# Current network connections
netstat -tuln > $outputDir/network_connections.txt

# Running processes
ps aux > $outputDir/running_processes.txt
EOF
"@

    Invoke-Expression $sshCommand
}

# Main script
$ips = @()

while ($true) {
    $IPinput = Read-Host "Enter an IP address or press Enter to finish"

    if ([string]::IsNullOrWhiteSpace($IPinput)) {
        break
    }

    $ips += $IPinput
}

if ($ips.Count -eq 0) {
    $filePath = Read-Host "Enter the path to the file containing IP addresses"
    if (Test-Path $filePath) {
        $ips = Get-Content $filePath
    } else {
        Write-Output "File not found. Exiting."
        exit
    }
}

$homeDir = [System.Environment]::GetFolderPath("UserProfile")
$baselineDir = Join-Path $homeDir "Baseline"

if (-not (Test-Path $baselineDir)) {
    New-Item -Path $baselineDir -ItemType Directory
}

foreach ($ip in $ips) {
    $ipDir = Join-Path $baselineDir $ip
    if (-not (Test-Path $ipDir)) {
        New-Item -Path $ipDir -ItemType Directory
    }

    Get-LinuxSystemInfo -ip $ip -outputDir $ipDir

    Write-Output "Information for $ip has been saved to $ipDir"
}