<#
    .SYNOPSIS
    Script to Baseline Windows systems.

    .DESCRIPTION
    This is a script for baselining Windows systems. 

    .PARAMETER TargetFile
    Text file containing each IP the script should be run on, seperated by line.
    Pleaase ensure there are no empty lines at the end of the file as it will cause errors.
#>
[CmdletBinding()]


# TODO ADD IN THE CUSTOM FUNCTIONS I BUILT FOR FIREWALL REGISTRY AND SCHEDULED TASKS & FIX THE COMMAND ARRAYS (LINE 78 DOWN)

param (

    [parameter(Position=0, Mandatory=$true, HelpMessage="Name of text file containing targets")] [string]$TargetFile
    )

# Console is cleared for reability purposes
[System.Console]::Clear()

# Date in mmddyy format
$Date = Get-Date -UFormat %m%d%y
$Time = Get-Date -DisplayHint Time -Format HHmm

# Prompt user for credentials
$Creds = Get-Credential

# TODO this may be removed - Thurlow User and Pass are stored individually for psexec
$User = $Creds.UserName
$Pass = $Creds.GetNetworkCredential().Password

# TODO THIS MAY NEED TO BE MODIFIED TO FIT GENERAL PURPOSE - Ask what tail this is being run on
$Tailnum = Read-Host "What Tail is this being run on?"

# TODO THIS MAY NEED TO BE MODIFIED FOR GENERAL PURPOSE Variables are created for local script path, primarily for output purposes
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition -ErrorAction Stop
$OutputPath = "$HOME\Documents\ScriptOutput_TODO"

# The following creates the form/buttons rtequired for the partial baseline function
Add-Type -AssemblyName System.Windows.Forms
$Form1 = New-Object System.Windows.Forms.Form
$Form1.StartPosition = 'CenterScreen'
$Form1.Size = '300,210'

$flp = New-Object System.Windows.Forms.FlowLayoutPanel
$Form1.Controls.Add($flp)
$flp.Name = 'MyFlowPanel'
$w = $Form1.Width.ToString()
$flp.Size = "$w,130"
$flp.FlowDirection = 'LeftToRight'
$flp.WrapContents = $true

'Process Pull','Service Pull','User Pull','Group Pull','NetTCP','AutoRuns','Installed Software','IP Configuration','Registry Pull','Directory Walk','Hash Walk','Scheduled Tasks','Firewall Rules' |
    ForEach-Object {

    $rb = New-Object System.Windows.Forms.CheckBox

    $flp.Controls.Add($rb)
    $rb.Text = $_
    $rb.AutoSize = $true

    }
$btn = New-Object System.Windows.Forms.Button
$Form1.Controls.Add($btn)
$btn.Text = 'Run'
$btn.DialogResult = 'OK'
$btn.Location = '100,140'

<#
The following objects represent each command to be run as part of a baseline.
They each contyain a command and name.
#>
$Procs = @{
    Command = {COMMAND}
    Name = "Process Pull"
    }
$Services = @{
    Command = {COMMAND}
    Name = "Service Pull"
    }
$NetTCP = @{
    Command = {COMMAND}
    Name = "NetTCP"
    }
$Users = @{
    Command = {COMMAND}
    Name = "User Pull"
    }
$Groups = @{
    Command = {COMMAND}
    Name = "Group Pull"
    }
$Software = @{
    Command = {COMMAND}
    Name = "Installed Software"
    }
$IPConf = @{
    Command = {COMMAND}
    Name = "IP Configuration"
    }
$Registry = @{
    Command = {COMMAND}
    Name = "Registry Pull"
    }
$Hashwalk = @{
    Command = {COMMAND}
    Name = "Hash Walk"
    }
$Dirwalk = @{
    Command = {COMMAND}
    Name = "Directory Walk"
    }
$Schtasks = @{
    Command = {COMMAND}
    Name = "Scheduled Tasks Pull"
    }
$Autoruns = @{
    Command = {COMMAND}
    Name = "Autoruns"
    }
$Firewall = @{
    Command = {COMMAND}
    Name = "Firewall Rules"
    }

# An initial array is created containing all default commands
$StandardCommands = ($Procs, $Services, $NetTCP, $Users, $Groups, $Software, $IPConf, $Registry, $Schtasks, $Autoruns, $Firewall)

# Another array containing all possible commands, needed for menu when partial basline is selected
$AllCommands = ($Procs, $Services, $NetTCP, $Users, $Groups, $Software, $IPConf, $Registry, $Schtasks, $Autoruns, $Firewall, $Hashwalk, $Dirwalk)

# New arrays are created to be used for Command and Error Output
$OutputArray = [System.Collections.ArrayList]::new()
$ErrorArray = [System.Collections.ArrayList]::new()

# A separate array is created for commands to be added to if user selects a partial baseline
$CommandsToRun = [System.Collections.ArrayList]::new()

#Loops through a Main Menu for the user to select desired type of baseline
:MainMenu while ($CommandsToRun.Count -eq 0) {
    Write-Host "Would you like to run a full baseline?"
    $Question1 = Read-Host "For a full baseline, type 'yes' or 'y'. To only run specific commmands, type 'no' or 'n'"

    switch($Question1){
        { ($_ -eq 'y') -or ($_ -eq 'yes') }{
        #User wants to run all commands, so this just copies all of them from one array to the other.
            $CommandsToRun = $StandardCommands
            breack MainMenu
            }
            { ($_ -eq 'n') -or ($_ -eq 'no') }{
            # Breaks to a submenu if the user elects to run a partial baseline
            :SubMenu while ($true) {
                $Form1.ShowDialog()
                foreach ($Checkbox in $flp.Controls) {
                    if ($Checkbox.Checked){
                        Foreach ($Command in $AllCommands) {
                            if ($Command.Name -eq $Checkbox.Text) {
                                [void]$CommandsToRun.Add([PSCustomObject]$Command)
                            }
                        }
                    }
                }
                Break
            }
            Break MainMenu
        }
        # If the user does not enter any options, prompt again
        { ($_ -eq "") }{
            Clear-Host
            "Please enter an option. `n"
            break
        }
        Default {
            Clear-Host
            "Try again. `n"
            break
        }
    }
}
$Targets = Get-Content $TargetFile

$Progress = 0

foreach ($Target in $Targets) {

    $CommandCount = $CommandsToRun.Count
    $TargetCount = $Targets.Count

    #Test Connection to the Target IP. If it fails, move to the next IP
    if(!(Test-Connection -Quiet $Targets -Count 1 -ErrorAction Stop)){
        [void]$ErrorArray.Add("Target : Connection Failure"); continue
        }

    #Create overall output folder if it doesn't already exist
    if(!(Test-Path -PathType Container -Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath
        }

    #Create a target-specific folder if it doesn't exist
    if(!(Test-Path -PathType Container -Path $TargetOutput)) {
        New-Item -ItemType Directory -Path $TargetOutput
        }
    # Create a Remote PowerShell Session
    $Session = New-PSSession -ComputerName $Target -Credential $Creds

    #Runs through the array of command strings and executres them on target system
    foreach ($Command in $CommandsToRun) {
        $Progress += (100/$CommandCount/$TargetCount)
        $CommandOutput = "$TargetOutput\$($Target)_$($Command.Name).csv"

        Write-Progress -Activity "Running Baseline" -CurrentOperation "Currently running $($Command.Name) on $($Target)" -PercentComplete ($Progress)

        # Splits the syntax based on the command being run
        if ($Command.Name -eq "Autoruns") {
            Invoke-Command -ScriptBlock $Autoruns.Command > $CommandOutput
        }
        else {
            Invoke-Command -Session -ScriptBlock $Command.Command | Select-Object -ExcludeProperty RunSpaceId, PSComputerName | Export-CSV -NoTypeInformation $CommandOutput
            }
        }
    #Closes current session before moving on
    Remove-PSSession -Session $Session
    }