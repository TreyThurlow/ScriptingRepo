# Define the local path to save CSV files
$localPath = Join-Path $env:USERPROFILE "Baseline"

# Ensure the Baseline folder exists, if not, create it
if (-not (Test-Path $localPath -PathType Container)) {
    New-Item -Path $localPath -ItemType Directory | Out-Null
}

# Define the path to autorunsc.exe
$autorunsPath = "C:\Path\To\autorunsc.exe"

# Define the script blocks for each command, including Autoruns
$scriptBlocks = @(
    { Get-ScheduledTask | Select-Object Author, Date, Description, TaskName, TaskPath, State },
    { Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run* },
    { Get-WmiObject -Class Win32_Service | Sort-Object -Property State, Name | Select-Object State, Name, DisplayName, ProcessId, PathName, StartMode },
    { Get-NetTCPConnection | Select-Object OwningProcess, LocalAddress, LocalPort, RemoteAddress, RemotePort, State },
    { Get-LocalUser -Name * | Select-Object Name, SID, Enabled, Description },
    { Get-LocalGroup -Name * | Select-Object Name, SID, Description },
    { Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, InstallDate, Publisher },
    { Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Select-Object Caption, Description, DNSHostName, DHCPEnabled, DHCPServer, IPAddress, DefaultIPGateway, DNSServerSearchOrder, MACAddress, Manufacturer },
    { Get-ChildItem -Recurse C:\ | Select-Object FullName, CreationTime, LastAccessTime, LastWriteTime },
    { Get-NetFirewallRule -All },
    {
        param ($autorunsPath)

        # Copy autorunsc.exe to a temporary directory
        $tempPath = Join-Path $env:TEMP "autorunsc.exe"
        Copy-Item -Path $autorunsPath -Destination $tempPath -Force

        # Run autorunsc.exe and export its output to CSV
        $autorunsOutput = & $tempPath -accepteula -a autorun

        # Delete the copied autorunsc.exe
        Remove-Item -Path $tempPath -Force

        # Output the autoruns output
        $autorunsOutput
    }
)

# Initialize an array to store jobs
$jobs = @()

# Loop through the computer list and execute each script block on each remote computer
foreach ($comp in $computerlist) {
    # Create a folder for the IP address inside the Baseline folder
    $ipFolderPath = Join-Path $localPath $comp
    if (-not (Test-Path $ipFolderPath -PathType Container)) {
        New-Item -Path $ipFolderPath -ItemType Directory | Out-Null
    }

    if ($comp -notlike "192.168.1.*") {
        # Use $seatcred for systems with IP addresses not in the 192.168.1.x range
        $cred = $seatcred
    }
    else {
        # Use $WINSRVCred for other systems
        $cred = $WINSRVCred
    }

    # Execute each script block on the remote computer as a background job
    foreach ($scriptBlock in $scriptBlocks) {
        $jobs += Invoke-Command -ComputerName $comp -ScriptBlock $scriptBlock -ArgumentList $autorunsPath -Credential $cred -AsJob
    }
}

# Wait for all jobs to complete
$jobs | Wait-Job

# Collect results from all jobs
$results = $jobs | Receive-Job

# Export results to CSV files inside respective IP folders
foreach ($result in $results) {
    $result | Export-Csv -Path (Join-Path $localPath "$($result.GetType().Name).csv") -NoTypeInformation
}

# Display any errors
$errors = $jobs | Where-Object { $_.State -eq "Failed" }
if ($errors.Count -gt 0) {
    Write-Host "Errors occurred during script execution:"
    $errors | ForEach-Object { Write-Host $_.Location }
}
