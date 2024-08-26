# Finds and sets the location to the Blue Team Scripts Folder
Get-ChildItem -Recurse $HOME | Where-Object -Property Name -EQ "BlueTeamScripts" | Set-Location

# Installs all modules and functions in the Modules folder.
Install-Module .\Modules\Invoke-CommandAs\Invoke-CommandAs.psm1 -Scope CurrentUser

# Sets location ot the Scripts Folder
Set-Location .\Scripts

# Creates the Output Folder for Script Output
$outputfolder = "$HOME\Documents\ScriptOutput"
if (-not (Test-Path $outputfolder -PathType Container)) {
            New-Item -Path $outputfolder -ItemType Directory | Out-Null
}

# Gets the Date
$date = Get-Date -Format dd-MMM-yy

# Gets the credentials (for MPN)
$creds = Get-Credential

# Begins a transcript
Start-Transcript -Path $HOME\Documents\PowerShellTranscript_$date.txt -IncludeInvocationHeader -Append

# Clears the PowerShell Terminal
Clear-Host