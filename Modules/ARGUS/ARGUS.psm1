<#
Version 1.2
Updated 24OCT2022
#>

Function Get-ARGUSStatusCheck {
<#
.SYNOPSIS
    Creates custom object for host to return status check information.
.NOTES
Author: Sean Bryla, JC331
Updated by: SSgt Trey Thurlow, NPES NCOIC, JCA
#>

[cmdletbinding()]
param()
    $MemInfo = ARGUS-GetMemoryInfo
    $Hash = [ordered]@{
        HostName= $env:COMPUTERNAME
        DiskInfo = [string](ARGUS-GetVolumeInfo)
        Services = ARGUS-StartServices
        "Evt-App" = ARGUS-GetApplicationLog
        "Evt-Sys" = ARGUS-GetSystemLog
        "Uptime (Hours)" = ARGUS-GetUpTime
        "Patches/Hotfix" = ARGUS-GetHotfix
        "Last SWUpdate" = ARGUS-GetSWUpdate
        Datfile = ARGUS-GetDATFile
        MemUsage = $MemInfo.usage
        "Mem %" = $MemInfo.Percent
        CPU = [string](ARGUS-GetCPUTime)
        Replication = ARGUS-GetReplicationStatus
        Cluster = ARGUS-GetClusterStatus
        DFSR = ARGUS-GetDFSRStatus
        Backups = ARGUS-GetBackups
        VM = ARGUS-TestVM
        Errors = $ARGUSErrorLog
    }
    New-Object psobject -Property $Hash
}
Function Enumerate-DataStores {
    Param(  [parameter()] $Name )
        Foreach ($I in $($name.extensiondata.datastore.value)) {
            $DataStores | Where-Object {$_.id -like "*$I"} | Select-Object -ExpandProperty name
        }
}
Function Enumerate-VMs {
    Param(  [Parameter()] $VMHost   )
        Foreach ($I in $($VMHost.extensiondata.vm.value)) {
            $VMs | Where-Object {$_.id -like "*$I"} | Select-Object -ExpandProperty name
        }
}
Function Invoke-ARGUSStatusCheck {
<#
.SYNOPSIS
    Issues StatusCheck command to remote Windows hosts
.NOTES
Author: Sean Bryla, JC331
Updated by: SSgt Trey Thurlow, NPES NCOIC, JCA
Update Date: 24OCT2022
#>
[cmdletbinding()]
Param(
    [Parameter( Mandatory,
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true,
                HelpMessage="List of Computernames." )]
    [ValidateNotNullOrEmpty()]
    [Alias('HostName')]
    [string[]]$ComputerName,
    [Parameter()]
    [ValidateNotNull()]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $credential = [System.Management.Automation.PSCredential]::Empty
)
Begin {$ScriptBlock = {Get-ARGUSStatusCheck}
       $StepCounter = 0
}
Process {$ComputersToScan += $ComputerName}
End {
    $script:Steps = ($ComputersToScan.Count * 2)
    #region Start Job Block
    Foreach ($Computer in $ComputersToScan) {
        ARGUS-ProgressBar -StepNumber ($stepcounter++) -title "Issuing Remote Command" -message "Computer"
        if ($credential -eq [System.Management.Automation.PSCredential]::Empty) {
            Write-Verbose "Issuing Command to $Computer"
            [psobject[]]$StatusJobs += Invoke-Command -ComputerName $Computer -ScriptBlock $ScriptBlock -AsJob
        }
        else {
            Write-Verbose "Issuing Command to $Computer"
            [psobject[]]$StatusJobs += Invoke-Command -ComputerName $Computer -ScriptBlock $ScriptBlock -Credential $Credential -AsJob -ErrorAction Stop
        }
    }
    #endregion Start Job Block
    #region Wait Job Block
    Foreach ($job in $StatusJobs) {
        ARGUS-ProgressBar -StepNumber ($StepCounter++) -title "Listening for reply..." -message "$($job.location)"
        Write-Verbose "Waiting for reply from $($job.location)"
        [void]($job | Wait-Job)
    }
    Write-Progress -Activity "Listening for reply..." -Completed
    #endregion Wait Job Block
    #region Receive Job Block
    foreach ($job in $StatusJobs) {
        Try {
            Receive-Job $job -ErrorAction Stop | Select-Object * -ExcludeProperty PSComputerName, RunspaceID, PSShowComputerName}
            Catch {
                Write-Warning "Unable to connect to $($job.location) - $($_.fullyQualifiedErrorID.split(",")[0])"
                $hash = [ordered]@{
                    HostName = $($job.location)
                    DiskInfo = ""
                    Services = ""
                    "Evt-App" = ""
                    "Evt-Sys" = ""
                    "UpTime (Hours)" = ""
                    "Patches/HotFix" = ""
                    "Last SWUpdate " = ""
                    DatFile = ""
                    MemUsage = ""
                    "Mem %" = ""
                    CPU = ""
                    Replication = ""
                    Cluster = ""
                    DFSR = ""
                    Backups = ""
                    VM = ""
                    Errors = "Unable to connect to $($job.location) - $($_.fullyQualifiedErrorId.split(",")[0])"
                }
                New-Object psobject -Property $hash
            }
    }
    #endregion Receive Job Block
    $StatusJobs | Remove Job }
}
Function ARGUS-VMHostStatus {
<#
.SYNOPSIS
    Issues StatusCheck command to remote Windows hosts.
.NOTES
Author: Sean Bryla, JC331
Updated by: SSgt Trey Thurlow, NPES NCOIC, JCA
Update Date: 24OCT2022
#>
    Write-Verbose "Talking to ESXI..."
    $Script:VMHosts = Get-VMHost
    $Script:VMs = Get-VM | Where-Object {$_.PowerState -eq "PoweredOn"} | Sort-Object name
    $Script:DataStores = Get-Datastore | Sort-Object name


    Foreach ($VMHost in $VMHosts) {
        $Hash = [ordered]@{
            HostName = ($VMHost.name).split(",")[0]
            "Overall Status" = $VMHost.extensiondata.OverallStatus.tostring().toupper()
            "Uptime (Hours)" = ($VMHost.extensiondata.Summary.QuickStats.Uptime / 3600).ToString("0.00")
            MemUsage = "$(($VMHost.MemoryUsageGB).tostring("0.00"))GB"
            "Mem %" = ($VMHost.MemoryUsageGB / $VMHost.MemoryTotalGB).ToString("P")
            CPU = (($VMHost.extensiondata.Summary.QuickStats.OverallCPUUsage) / $VMHost.CPUTotalMhz).ToString("P")
            VMs = [string](Enumerate-VMs -VMHost $VMHost)
            Datastores = (Enumerate-DataStores -Name $VMHost).Count
        }
        New-Object PSObject -Property $Hash
    }
}
Function ARGUS-VMStatus {
    Foreach ($VM in $VMs) {
        $hash = [ordered]@{
            HostName = $VM.name
            GuestOS = $VM.Guest.ToString().Split(":")[1]
            Heartbeat = $VM.extensiondata.guestheartbeatstatus.ToString().toupper()
            Datastore = [string](Enumerate-DataStores -Name $VM)
        }
    }
}
Function ARGUS-DatastoreStatus {
    Foreach ($Datastore in $Datastores) {
        $hash = [ordered]@{
            Datastore = $Datastore.name
            Status = $Datastore.extensiondata.OverallStatus.ToString().toupper()
        }
        New-Object psobject -Property $hash
    }
}
Function Argus {
<#
.SYNOPSIS
    Calls all status check functions and exports results to a log file.
.NOTES
Author: Sean Bryla, JC331
Updated by: SSgt Trey Thurlow, NPES NCOIC, JCA
Update Date: 24OCT2022
#>
    $Year = Get-Date -Format "yyyy"
    $Month = (Get-Date -Format M).Split(" ")[0]
    $FileName = ((Get-Date -Format "t").Split(":")[0] + (Get-Date -Format "mm") + "Z - " + (Get-Date -Format "dd") + $Month)
    $Path = "\\SERVERNAME\PATH\TO\DAILYCHECKSLOCATION\$Year\$Month"
    $HTMLPath = "\\SERVERNAME\PATH\TO\DAILYCHECKSLOCATION\$Year\$Month"
    $ServerList = Get-Content "\\PATH\TO\COMPUTER_OR_SERVER\LIST"
    $Header = "
    <style>
    Table {
        font-size: 12px;
        border: 0px;
        font-family: Arial, Helvetica, Sans-serif;
    }
    th {
        background: #395870;
        background: linear-gradient(#49708f,#293f50);
        color: #fff;
        font-size: 11px;
        text-transform: uppercase;
        padding: 10px 15px;
        vertical-align: middle;
    }
    tbody tr:nth-child(even){
        background: #f0f0f2;
    }
    </style>
    "
# The below function checks/asks for credentials to be able to log into Domain Controllers. 
    Function Cred-Check {
        $Script:Cred9 = Get-Credential DOMAIN\
        if (!(Invoke-Command -ComputerName DC01 -Credential $Cred9 -ScriptBlock {"True"} -ErrorAction SilentlyContinue)) {
            #Recurse if authentication fails
            Write-Host -ForegroundColor Yellow "Username or Password was incorrect. Press enter to try again or Ctrl+C to cancel"
            Pause
            Cred-Check
        }
        Else {Main}
    }
    #The below function is the main portion of the Daily Checks
    Function Main {
        # Make a new folder if it doesn't exist
        if (!(Test-Path $Path)) {mkdir $Path}
        #Connect to vCSA using PowerCLI Module
        <#Write-Verbose "Connecting to vCSA on VCENTERNAME..."
        Try {[void](Connect-VIServer VCENTER.DOMAIN)}
        Catch {
            Write-Error "FATAL! Unable to connect to VCENTERNAME!"
            Pause
            Exit
        }#>

        $DCs = Invoke-ARGUSStatusCheck -ComputerName DC01,DC02 -credential $Cred9 | ConvertTo-Html -Fragment -PreContent "<h2>Domain Controllers</h2>"
        $windows = $ServerList |Invoke-ARGUSStatusCheck | ConvertTo-Html -Fragment -PreContent "<h2>Hosts</h2>"
        $VMHosts = ARGUS-VMHostStatus | ConvertTo-Html -Fragment -PreContent "<h2>VM Hosts</h2>"
        $VMs = ARGUS-VMStatus | ConvertTo-Html -Fragment -PreContent "<h2>Virtual Machines</h2>"
        $Datastores = ARGUS-DatastoreStatus | ConvertTo-Html -Fragment -PreContent "<h2>Datastores</h2>"
        $Report = ConvertTo-Html -Body "$DCs $Windows $VMHosts $VMs $Datastores" -Title "Status Report $Filename" -Head $Header

        $Report | Out-File "$HTMLPath\$FileName.html"
        Write-Host -ForegroundColor Green "Results Saved to:" -NoNewline
        Write-Host "$HTMLPATH\$FileName"
        if (!(Test-Path $HTMLPath)) {mkdir $HTMLPath}
    }
    Cred-Check
}
Function ARGUS-GetVolumeInfo {
<#
.SYNOPSIS
    Discovers all named volumes on all disks (a through z) then calculates percentage used.
.NOTES
Author: Sean Bryla, JC331
Updated by: SSgt Trey Thurlow, NPES NCOIC, JCA
Update Date: 24OCT2022
#>
    Write-Verbose "Getting Filesystem Info"
    # Discover named volumes (a-z) on disk, store in $volumes[]
    foreach ($Drive in $(Get-Volume | Where-Object {$_.DriveLetter -ne $Null -and $_.DriveType -eq "Fixed" - $_.Size -ne 0})) {
        <# The array of customPSobjects was not properly exporting to CSV --15SEP2020
        $Hash = @{
            DriveLetter = ($Drive.Driveletter).tostring()
            FreeSpace = ($Drive.SizeRemaining / $Drive.size).ToString("P")
        }
        [psobject[]]$VolumeInfo += New-Object psobject -Property $Hash
        #>
        "$($Drive.DriveLetter):\($($Drive.FilesystemLabel)) - $((($Drive.SizeRemaining / $Drive.size)*100).ToString("0.00"))% Remaining`n"

    # Capacity Threshold check
        If (($Drive.SizeRemaining / $Drive.size) -le .2) {[string[]]$Script:ARGUSErrorLog += "$($Drive.DriveLetter):\ over 80% Capacity"}
    }
}
Function ARGUS-StartServices {
<#
.SYNOPSIS
    Discovers services that are currently stopped and set to start automatically, then starts them.
.NOTES
Author: Sean Bryla, JC331
Updated by: SSgt Trey Thurlow, NPES NCOIC, JCA
Update Date: 24OCT2022
#> 
    Write-Verbose "Starting Services"
    # Discover Stopped Services set to 'Automatic' Start-up, store in $StoppedArrays
    $StoppedArray = Get-Service | Where-Object {$_.StartType -eq "Automatic" -AND $_.Status -eq "Stopped"}
    $ServiceErrors = 0
    # Start services
    Foreach ($Service in $StoppedArray) {
        Try {Start-Service $Service -ErrorAction Stop}
        Catch {
            [string[]]$Script:ARGUSErrorLog =+ "$($_.fullyQualifiedErrorID.split(",")[0]) - $($_.TargetObject.name)"
            $ServiceErrors++
        }
    }
    If ($ServiceErrors -ne 0) {"$ServiceErrors errors"}
    Else {"OK"}
}
Function ARGUS-GetApplicationLog {
<#
.SYNOPSIS
    Returns Application Event Log Errors from previous 24 hours
.NOTES
Author: Sean Bryla, JC331
Updated by: SSgt Trey Thurlow, NPES NCOIC, JCA
Update Date: 24OCT2022
#>
    Write-Verbose "Getting Application Log Errors"
    (Get-EventLog -LogName Application -EntryType Error -ErrorAction Ignore -After (Get-Date).AddHours(-24)).count
}
Function ARGUS-GetSystemLog {
<#
.SYNOPSIS
    Returns System Event Log Errors from previous 24 hours
.NOTES
Author: Sean Bryla, JC331
Updated by: SSgt Trey Thurlow, NPES NCOIC, JCA
Update Date: 24OCT2022
#>
    Write-Verbose "Getting System Log Errors"
    (Get-EventLog -LogName System -EntryType Error -After (Get-Date).AddHours(-24) -ErrorAction Ignore | Where-Object {$_.Source -ne "netlogon" -or $_.Source -ne "SChannel"}).count
}
Function ARGUS-GetUpTime {
<#
.SYNOPSIS
    Returns OS Uptime
.NOTES
Author: Sean Bryla, JC331
Updated by: SSgt Trey Thurlow, NPES NCOIC, JCA
Update Date: 24OCT2022
#>  
    Write-Verbose "Getting Uptime"
    ((Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime).totalhours.tostring("#,0.00")
}
Function ARGUS-GetHotfix {
<#
.SYNOPSIS
    Returns Latest Hotfix
.NOTES
Author: Sean Bryla, JC331
Updated by: SSgt Trey Thurlow, NPES NCOIC, JCA
Update Date: 24OCT2022
#>  
    Write-Verbose "Getting lastest Hotfix"
    $HotFix = Get-HotFix | Select-Object -last 1 HotfixID, @{L="InstalledOn";e={$_.installedon.toshortdatestring()}}
    "$($HotFix.HotfixID) - $($HotFix.InstalledOn)"
}
Function ARGUS-GetSWUpdate {
<#
.SYNOPSIS
    Returns Latest Hotfix
.NOTES
Author: Sean Bryla, JC331
Updated by: SSgt Trey Thurlow, NPES NCOIC, JCA
Update Date: 24OCT2022
#>  
    Write-Verbose "Getting latest Software Update"
    (Get-ChildItem HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Sort-Object installdate -Descending | Select-Object -First 1).installdate    
}
Function ARGUS-GetDATFile {
<#
.SYNOPSIS
    Returns Latest McAfee/Trillex DAT File
.NOTES
Author: Sean Bryla, JC331
Updated by: SSgt Trey Thurlow, NPES NCOIC, JCA
Update Date: 24OCT2022
#>    
    Write-Verbose "Getting latest .DAT File"
    Try {(Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\McAfee\AVEngine -ErrorAction Stop).AVDatDate}
    catch [System.Management.Automation.ItemNotFoundException]{(Get-ItemProperty HKLM:\SOFTWARE\McAfee\AVSolution\DS\DS -ErrorAction Stop).szContentCreationDate}
    Catch {"ERROR"}
}
Function ARGUS-GetMemoryInfo {
<#
.SYNOPSIS
    Returns Memory Utilization
.NOTES
Author: Sean Bryla, JC331
Updated by: SSgt Trey Thurlow, NPES NCOIC, JCA
Update Date: 24OCT2022
#>    
    Write-Verbose "Getting Memory Info"
    $Script:CIM_ComputerSystem = Get-WmiObject -Class win32_ComputerSystem
    $TotalRam = $CIM_ComputerSystem.totalphysicalmemory
    $availMem = (Get-Counter '\Memory\Availble Bytes').countersamples.cookedvalue
    $InUseMem = $TotalRam - $availMem
    $Hash = @{
        Usage = "$(($InUseMem / 1GB).ToString("#,0.00"))/$(($TotalRam/1GB).ToString("#,0.00"))GB"
        Percent = "$(($InUseMem / $TotalRam).ToString("P"))"
    }
    New-Object psobject -Property $Hash
}
Function ARGUS-GetCPUTime {
<#
.SYNOPSIS
    Returns CPU Utilization
.NOTES
Author: Sean Bryla, JC331
Updated by: SSgt Trey Thurlow, NPES NCOIC, JCA
Update Date: 24OCT2022
#> 
    Write-Verbose "Getting CPU Utilization"
    Foreach ($CPUTime in $((Get-CimInstance -Class CIM_Processor).LoadPercentage)){
        "$CPUTime%"
    }
}
Function ARGUS-GetReplicationStatus {
<#
.SYNOPSIS
    Returns DC Replication Status
.NOTES
Author: Sean Bryla, JC331
Updated by: SSgt Trey Thurlow, NPES NCOIC, JCA
Update Date: 24OCT2022
#>     
    Write-Verbose "Getting Replication Metadata"
    try {
        if ((Get-ADReplicationPartnerMetadata -Partition schema -target localhost -erroraction stop).LastReplicationResult) {"OK"}
        else {"ERROR"}
    }
    catch {
        "N/A"
    }
}
Function ARGUS-GetClusterStatus {
<#
.SYNOPSIS
    Returns Cluster Status
.NOTES
Author: Sean Bryla, JC331
Updated by: SSgt Trey Thurlow, NPES NCOIC, JCA
Update Date: 24OCT2022
#>  
    Write-Verbose "Getting Cluster Status..."
    try {
        foreach ($Node in $(Get-ClusterNode -ErrorAction stop).state) {
            if ($Node -ne "Up") {[string[]]$Out += "CLUSTER NODE ERROR: $($Node.name)"}
        }
        Foreach ($Resource in $(Get-ClusterResource -ErrorAction Stop).state) {
            if ($Resource -ne "Online") {[string[]]$Out += "CLUSTER RESOURCE ERROR: $($Resource.name)"}
        }
        if (!$Out) {"OK"}
    }
    catch {
        "N/A"
    }
}
Function ARGUS-GetDFSRStatus {
<#
.SYNOPSIS
    Returns DFSR Member Connection Status
.NOTES
Author: Sean Bryla, JC331
Updated by: SSgt Trey Thurlow, NPES NCOIC, JCA
Update Date: 24OCT2022
#>    
    Write-Verbose "Getting DFSR Status"
    $DFSRStatus = 0
    try {
        Foreach ($State in $((Get-DFSRConnection -ErrorAction Stop).state)) {
            if ($State -ne "Normal") {$DFSRStatus++}
        }
        if ($DFSRStatus -eq 0) {"OK"}
        Else {"ERROR"}
    }
    catch {
        "N/A"
    }
}
Function ARGUS-GetBackups {
<#
.SYNOPSIS
    Returns last backup date
.NOTES
Author: Sean Bryla, JC331
Updated by: SSgt Trey Thurlow, NPES NCOIC, JCA
Update Date: 24OCT2022
#> 
    Write-Verbose "Getting Backups..."
    try {
        (Get-WBSummary -ErrorAction Stop).lastsuccessfulbackuptime.toshortdatestring()
    }
    catch {
        "N/A"
    }    
}
Function ARGUS-TestVM {
<#
.SYNOPSIS
    Tests if host is a Virtual Machine
.NOTES
Author: Sean Bryla, JC331
Updated by: SSgt Trey Thurlow, NPES NCOIC, JCA
Update Date: 24OCT2022
#>     
    if ($CIM_ComputerSystem.model -like "VMware*") {"VM"}
    else {"N/A"}
}
Function ARGUS-ProgressBar {
<#
.SYNOPSIS
    Calculates and displays progress.
.NOTES
Author: Sean Bryla, JC331
Updated by: SSgt Trey Thurlow, NPES NCOIC, JCA
Update Date: 24OCT2022
#> 
Param (
    [int]$StepNumber,
    [string]$title,
    [string]$message
)    
    Write-Progress -Activity $title -Status $message -PercentComplete (($StepNumber / $steps) * 100)
}
Export-ModuleMember 'Invoke-ARGUSStatusCheck', 'Get-ARGUSStatusCheck', 'Argus'