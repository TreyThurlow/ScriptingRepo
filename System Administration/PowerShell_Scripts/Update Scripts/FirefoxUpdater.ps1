<#
.SYNOPSIS
    Updates Firefox to a specified version on multiple client computers.

.DESCRIPTION
    This script imports a module to get the Firefox version, prompts the user for the version number, and verifies the existence of the specified version in a shared folder.
    It then uses PowerShell remoting to connect to multiple client computers and updates Firefox to the specified version using msiexec.exe.
    The script handles errors and logs the update status for each client.

.EXAMPLE
    # Update Firefox on multiple client computers
    .\FirefoxUpdater.ps1
#>
# Import the module
Import-Module "PAth\To\Get-FireFoxVersion\FUNCTION"

# Prompt the user for the version number
$firefoxversion = Get-Version

# Define the path to the Firefox folder. There will be multiple versions, so verify the existence of the selected version.
$updatePath = "\\servername\sharename2\Mozilla\Firefox\$firefoxversion"
if (-not (Test-Path $updatePath)) {
    Write-Warning "Firefox version ('$firefoxversion') not found in '$updatePath'"
    exit
}

# Define the path to the msiexec.exe executable.
$msiexec = 'C:\windows\System32\msiexec.exe'

# Define a list of arguments to pass to msiexec.exe.
# These arguments will install the specified version of Firefox silently without prompting the user.
$argList = @(
    '/i'
    "`"$updatePath\Firefox Setup $($firefoxversion)esr.msi`""
    '/qn'
    '/quiet'
    '/passive'
    '/norestart'
)

# Use PowerShell remoting to connect to multiple client computers
$clients = Get-Content "\\servername\sharename\clients.txt"
$sessionPool = New-PSSession -ComputerName $clients -SessionOption (New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck) -ThrottleLimit 10
if ($sessionPool.Count -eq 0) {
    Write-Warning "No clients available for remote update"
    exit
}

# Iterate through each PowerShell session and update Firefox on each client computer
foreach ($session in $sessionPool) {
    # Try to execute the msiexec command remotely on the client computer.
    #If an error occurs, write a warning message to the console.
    Try {
        Invoke-Command -Session $session -ScriptBlock {
            Param($InstallArgs)
            Start-Process -FilePath $using:msiexec -ArgumentList $Args -Wait -NoNewWindow -PassThru
        } -ArgumentList $argList
        Write-Host "Firefox update for $($session.ComputerName) is complete."
    } Catch {
        Write-Warning "Could not update Firefox on $($session.ComputerName): $($($_.Exception.Message))"
    } finally {
        # Clean up the PowerShell session when done to free up resources.
        Remove-PSSession -Session $session
    }
}