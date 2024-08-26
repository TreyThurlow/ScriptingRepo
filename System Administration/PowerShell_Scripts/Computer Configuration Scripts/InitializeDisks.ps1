<#
.SYNOPSIS
Creates partitions and formats disks that do not currently have partitions.

.DESCRIPTION
This script identifies all disks that do not have any partitions (i.e., disks with a RAW partition style) and then creates a single partition using the maximum size available on each identified disk. After creating each partition, the script formats it with the NTFS file system and assigns a drive letter. A label 'Data' is also applied to each formatted volume. Finally, a confirmation message is printed for each disk processed.

.EXAMPLE
.\InitializeDisks.ps1
This example runs the script to create and format partitions on all RAW disks available in the system. The output will display a message confirming the completion of partitioning and formatting for each disk.
#>

# Get all disks that do not have partitions
$disks = Get-Disk | Where-Object { $_.PartitionStyle -eq 'RAW' }

# Create partitions with maximum size for each disk
foreach ($disk in $disks) {
    $size = $disk.Size / 1GB
    $partition = New-Partition -DiskNumber $disk.Number -UseMaximumSize -AssignDriveLetter
    Format-Volume -Partition $partition -DriveLetter $partition.DriveLetter -FileSystem NTFS -NewFileSystemLabel 'Data' -Confirm:$false
    Write-Output "Partition and format completed for disk $($disk.Number) with $($size) GB"
}