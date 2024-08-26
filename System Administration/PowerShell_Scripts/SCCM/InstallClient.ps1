<#
.SYNOPSIS
    Installs the SCCM client on a specified device.

.DESCRIPTION
    This script installs the SCCM client on a specified device by creating a PowerShell session to the device,
    running the client installer, and checking the installation log for errors. It uses the provided site server,
    site code, client install account, and log location.

.EXAMPLE
    Install-CMClient -Device "DeviceName"
    This command installs the SCCM client on the device named "DeviceName".
#>
# Replace these values with the correct details
$SiteServer = "yourserver.yourdomain.com"
$SiteCode = "PS100"
$ClientInstallAccount = "domain\admin"
$ClientLogLocation = "C:\Windows\Temp\ccmsetup.log"

# Function to install the SCCM client on a device
function Install-CMClient {
    param (
        [string]$Device
    )

    $session = New-PSSession -ComputerName $Device
    Invoke-Command -Session $session -ScriptBlock {
        $ClientInstallAccount = "$using:ClientInstallAccount"
        $ClientLogLocation = "$using:ClientLogLocation"
        $SiteCode = "$using:SiteCode"
        $SiteServer = "$using:SiteServer"

        $Arguments = "/mp:$SiteServer /logon SMSSITECODE=$SiteCode CCMLOGLEVEL=2"
        $Installer = "\\$SiteServer\sms_site$\client\ccmsetup.exe"
        $Process = Start-Process -FilePath $Installer -ArgumentList $Arguments -Credential $ClientInstallAccount -PassThru -Wait -NoNewWindow
        $ProcessExitCode = $Process.ExitCode

        Get-Content -Tail 50 $ClientLogLocation | Select-String -Pattern 'error' | ForEach-Object {
            $ErrorMsg = $_.ToString()
            Write-Host "Error: $ErrorMsg" -ForegroundColor Red
        }

        if ($ProcessExitCode -eq 0) {
            Write-Host "Successfully installed SCCM client on device $Device" -ForegroundColor Green
        }
        else {
            Write-Host "Failed to install SCCM client on device $Device with exit code: $ProcessExitCode" -ForegroundColor Yellow
        }
    }
    Remove-PSSession -Session $session
}

# Install the client on a list of devices
$DeviceList = Get-Content -Path "C:\deviceList.txt"
foreach ($Device in $DeviceList) {
    Install-CMClient -Device $Device
}