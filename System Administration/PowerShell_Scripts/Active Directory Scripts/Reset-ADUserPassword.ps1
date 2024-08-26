<#
.SYNOPSIS
    Resets a user's account password and unlocks the account on Active Directory.

.DESCRIPTION
    This script prompts the user to enter their domain admin credentials, the username, and the default password. It resets the user's account password to the default password, unlocks the account, and sets the account to require a password change at the next login.

.EXAMPLE
    PS C:\> .\Reset-ADUserPassword.ps1
    Enter the Username: JohnDoe
    Enter the Default Password: P@ssw0rd

    This example resets the password for the user 'JohnDoe' to 'P@ssw0rd', unlocks the account, and sets it to require a password change at the next login.
#>

#This command will allow you to run this script on your normal account, as long as you select your domain admin account.
$cred = Get-Credential

#Sets a variable for the username
$Identity = Read-Host "Enter the Username"

#Sets the default password into a variable
$Password = Read-Host "Enter the Default Password"

#Resets the User's account to the default Password
Set-ADAccountPassword -Identity $Identity -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$Password" -Force) -PassThru -Confirm:$false -Credential $cred

#Unlocks the User's account
Unlock-ADAccount -Identity $Identity -Credential $cred

#Allows the User to change their password at login
Set-ADUser -ChangePasswordAtLogon $true -Identity $Identity -Confirm:$false -verbose -Credential $cred

Write-Host "Password reset successful and set to change at next logon." -ForegroundColor Green