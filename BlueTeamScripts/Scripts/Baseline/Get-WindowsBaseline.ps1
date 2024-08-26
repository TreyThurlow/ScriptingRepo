<#
    .SYNOPSIS
        Conducts a baseline of remote systems.

    .DESCRIPTION
        This script will conduct a baseline of remote systems. You can import a text file or type in the IP Addresses of the remote computers that you wish to baseline. The script will output CSV/TXT files into a Baseline directory in the $HOME drive and will have all of the computers seperated by IP. 

    .EXAMPLE
        .\Get-WindowsBaseline.ps1
#>
# Prompt the user to choose between importing a computer list file or entering IPs manually
$choice = Read-Host "Do you want to import a computer list file or enter IPs? (Type 'Import' or 'Type')"

switch ($choice) {
    "Import" {
        # Get the file path from the user and read the computer list from the file
        $filePath = Read-Host "Enter the full file path of the computer list file."
        $computerList = Get-Content $filePath
    }
    "Type" {
        # Allow the user to manually enter IP addresses
        $computerList = @()
        do {
            $computer = Read-Host "Enter the IP address and press Enter."
            if ($computer -ne "") {
                $computerList += $computer
            }
        } while ($computer -ne "")
    }
    Default {
        # Handle invalid choices
        Write-Host "Invalid choice. Please choose 'Import' or 'Type'."
        Exit
    }
}

# Define the local path to save CSV files and Excel file
$localPath = Join-Path $env:USERPROFILE "Baseline"

# Ensure the Baseline folder exists, if not, create it
if (-not (Test-Path $localPath -PathType Container)) {
    New-Item -Path $localPath -ItemType Directory | Out-Null
}

# Define the script blocks for each command, including Autoruns
$scriptBlocks = @{
    Services = { Get-WmiObject -Class Win32_Service | Sort-Object -Property State, Name | Select-Object State, Name, DisplayName, PathName, StartMode }
    Processes = { Get-WMIObject win32_Process | Select-Object Name, ProcessId, ParentProcessId, ExecutablePath, CreationDate | Format-Table -Autosize }
    NetTCP = { Get-NetTCPConnection | Select-Object OwningProcess, LocalAddress, LocalPort, RemoteAddress, RemotePort, State }
    LocalUsers = { Get-LocalUser -Name * | Select-Object Name, SID, Enabled, Description }
    LocalGroups = { Get-LocalGroup -Name * | Select-Object Name, SID, Description }
    InstalledSoftware = { Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, InstallDate, Publisher }
    NetAdapter = { Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Select-Object Caption, Description, DNSHostName, DHCPEnabled, DHCPServer, IPAddress, DefaultIPGateway, DNSServerSearchOrder, MACAddress, Manufacturer }
    Dirwalk = { Get-ChildItem -Recurse C:\ | Select-Object FullName, CreationTime, LastAccessTime, LastWriteTime }
    Autoruns = { & "C:\Windows\system32\autorunsc64.exe" -h -accepteula -nobanner * }
}

# Initialize an array to store jobs
$jobs = @()

# Loop through the computer list and execute each script block on each remote computer
foreach ($comp in $computerList) {
    # Create a folder for the IP address inside the Baseline folder
    $ipFolderPath = Join-Path $localPath $comp
    if (-not (Test-Path $ipFolderPath -PathType Container)) {
        New-Item -Path $ipFolderPath -ItemType Directory | Out-Null
    }

    # Execute each script block on the remote computer as a background job
    foreach ($key in $scriptBlocks.Keys) {
        $scriptBlock = $scriptBlocks[$key]
        if ($key -eq "Autoruns") {
            # Use Invoke-CommandAs for Autoruns to run as System
            $jobs += Invoke-CommandAs -ComputerName $comp -ScriptBlock $scriptBlock -AsSystem -Credential $creds -AsJob -JobName "Autoruns" -ErrorAction SilentlyContinue
        } else {
            # Use Invoke-Command for other script blocks
            $jobs += Invoke-Command -ComputerName $comp -ScriptBlock $scriptBlock -Credential $creds -AsJob -JobName $key -ErrorAction SilentlyContinue
        }
    }
    # Additional commands for scpecial functions
    $jobs += Invoke-Command -ComputerName $comp -ScriptBlock ${function:Get-Firewall} -ArgumentList '*' -Credential $creds -AsJob -JobName "FirewallRules" -ErrorAction SilentlyContinue 
    $jobs += Invoke-Command -ComputerName $comp -ScriptBlock ${function:Get-ScheduledTaskActions} -ArgumentList '\' -Credential $creds -AsJob -JobName "ScheduledTasks" -ErrorAction SilentlyContinue 
    $jobs += Invoke-Command -ComputerName $comp -ScriptBlock ${function:Get-RegistryKeys} -ArgumentList 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Credential $creds -AsJob -JobName "RunKeys" -ErrorAction SilentlyContinue
    $jobs += Invoke-Command -ComputerName $comp -ScriptBlock ${function:Get-RegistryKeys} -ArgumentList 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' -Credential $creds -AsJob -JobName "RunOnceKeys" -ErrorAction SilentlyContinue
}

# Wait for all jobs to complete
$jobs | Wait-Job

# Collect results from all jobs
foreach ($job in $jobs) {
    $result = Receive-Job -Job $job
    $ipFolderPath = Join-Path $localPath $job.ComputerName
    if ($job.Name -eq "Autoruns") {
        # Export Autoruns results to a text file
        $result | Out-File -FilePath "$ipFolderPath\$($job.ComputerName)_Autoruns.txt"
    } else {
        # Export other results to CSV files
        $csvFileName = "$ipFolderPath\$($job.ComputerName)_$($job.Name).csv"
        $result | Export-Csv -Path $csvFileName -NoTypeInformation
    }
}