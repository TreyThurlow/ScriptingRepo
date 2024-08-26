################################################################################
# Define the hashtable with script blocks
$scriptBlocks = @{
    Processes = { Get-Process }
    Services = { Get-Service }
    # Add more script blocks as needed
}

# List of remote computer IPs or names
$computers = @("192.168.1.1", "192.168.1.2", "192.168.1.3")

# Total number of computers and jobs
$totalComputers = $computers.Count
$totalJobs = $scriptBlocks.Count

# Loop through each computer
for ($i = 0; $i -lt $totalComputers; $i++) {
    $comp = $computers[$i]
    Write-Output "Processing computer: $comp"

    # Array to store job information for the current computer
    $jobs = @()

    # Loop through each script block and start jobs
    for ($j = 0; $j -lt $totalJobs; $j++) {
        $key = $scriptBlocks.Keys[$j]
        Write-Output "Starting job for: $key on $comp"
        $job = Invoke-Command -ComputerName $comp -ScriptBlock $scriptBlocks[$key] -AsJob
        $jobs += [PSCustomObject]@{ Key = $key; Job = $job }

        # Update progress bar for job start
        Write-Progress -Activity "Processing $comp" -Status "Starting job $($j + 1) of $totalJobs" -PercentComplete (($j + 1) / $totalJobs * 100)
    }

    # Wait for all jobs to complete
    for ($j = 0; $j -lt $totalJobs; $j++) {
        $jobInfo = $jobs[$j]
        Write-Output "Waiting for job: $($jobInfo.Key) on $comp"
        Wait-Job -Job $jobInfo.Job

        # Update progress bar for job completion
        Write-Progress -Activity "Processing $comp" -Status "Completed job $($j + 1) of $totalJobs" -PercentComplete (($j + 1) / $totalJobs * 100)
    }

    # Retrieve and export results
    for ($j = 0; $j -lt $totalJobs; $j++) {
        $jobInfo = $jobs[$j]
        Write-Output "Retrieving results for: $($jobInfo.Key) on $comp"
        $results = Receive-Job -Job $jobInfo.Job

        # Define the CSV file name
        $csvFileName = "${comp}_${($jobInfo.Key)}.csv"

        # Export the results to a CSV file
        $results | Export-Csv -Path $csvFileName -NoTypeInformation

        # Update progress bar for result export
        Write-Progress -Activity "Processing $comp" -Status "Exported results for job $($j + 1) of $totalJobs" -PercentComplete (($j + 1) / $totalJobs * 100)
    }

    Write-Output "Completed processing for computer: $comp"

    # Clear the progress bar for the current computer
    Write-Progress -Activity "Processing $comp" -Status "Completed" -Completed
}

Write-Output "All jobs completed and results exported to CSV files."