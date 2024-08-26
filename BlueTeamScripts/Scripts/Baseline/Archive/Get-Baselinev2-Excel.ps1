# Define the local path to save CSV files and Excel file
$localPath = Join-Path $env:USERPROFILE "Baseline"
$excelFilePath = Join-Path $localPath "CombinedResults.xlsx"
# TODO VERIFY COMPUTER LIST VARIABLE
# Ensure the Baseline folder exists, if not, create it
if (-not (Test-Path $localPath -PathType Container)) {
    New-Item -Path $localPath -ItemType Directory | Out-Null
}

# Define the path to autorunsc.exe
$autorunsPath = "C:\Path\To\autorunsc.exe"

# Define the script blocks for each command, including Autoruns
$scriptBlocks = @(
    { Get-ScheduledTask | Select-Object Author, Date, Description, TaskName, TaskPath, State },
    #TODO ADD A GET PROCESS COMMAND WITH WMI { }
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

# Initialize Excel application
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$workbook = $excel.Workbooks.Add()

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

# Loop through each IP folder and each CSV file within it
foreach ($ipFolder in Get-ChildItem -Path $localPath -Directory) {
    $ipAddress = $ipFolder.Name
    $worksheet = $workbook.Worksheets.Add()
    $worksheet.Name = $ipAddress

    foreach ($csvFile in Get-ChildItem -Path $ipFolder.FullName -File -Filter "*.csv") {
        # Add a title before importing each CSV
        $worksheet.Cells.Item($worksheet.UsedRange.Rows.Count + 2, 1) = "CSV: $($csvFile.BaseName)"
        $worksheet.Cells.Item($worksheet.UsedRange.Rows.Count + 3, 1) = "Imported on: $(Get-Date)"

        $csvData = Import-Csv -Path $csvFile.FullName
        $rowCount = $csvData.Count
        $columnCount = $csvData[0].PSObject.Properties.Count

        $range = $worksheet.Range("A1").Resize($rowCount + 1, $columnCount)
        $range.Value = ($csvData | ConvertTo-Csv -Delimiter "`t" -NoTypeInformation | Out-String | ConvertFrom-Csv -Delimiter "`t").PSObject.Properties.Value
        $range.EntireColumn.AutoFit() | Out-Null
    }
}

# Save and close the Excel file
$workbook.SaveAs($excelFilePath)
$excel.Quit()

# Clean up Excel COM objects
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()

Write-Host "Excel file created: $excelFilePath"
