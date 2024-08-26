<#
.SYNOPSIS
    Finds and manages inactive Active Directory users.

.DESCRIPTION
    This script identifies inactive Active Directory users based on their last logon date and either disables or deletes them. 
    It allows specifying different organizational units (OUs) and account types for targeted management. 
    The results are exported to a CSV file for reporting purposes.

.EXAMPLE
    .\InactiveUsersManagement.ps1
    Prompts for the type of account (User, 7, 8, 9) and the path to save the results. 
    Finds inactive users in the specified OU, exports the results to a CSV file, and disables the inactive accounts.
#>

Import-Module ActiveDirectory

# Sets the variables
$DaysInactive = 30
$DaysInactiveForDeletion = 90
$DeletionDate = (Get-Date).Adddays(-($DaysInactiveForDeletion))
$InactiveDate = (Get-Date).Adddays(-($DaysInactive))
$UserOU = "OU=Users,DC=dd,DC=my,DC=domain"
$7AccountOU = "OU=System Admins 7,DC=dc,DC=smil,DC=mil"
$8AccountOU = "OU=Server Admins 8,DC=dd,DC=my,DC=domain"
$9AccountOU = "OU=Admin Accounts 9,DC=dd,DC=my,DC=domain"
$ResultDest = Read-Host "Type the full path where you would like to save the results (C:\Users\USERNAME\Documents\). ONLY THE PATH. The script will handle the filename."
$Date = Get-Date -Format "yyyy-MM-dd"
$ResultFile = $ResultDest + "DisabledInactiveUsers" + "_" + $Date + ".csv"
#-------------------------------
# FIND INACTIVE USERS
#-------------------------------
$AccountType = Read-Host "Specify the type of account that you want (User, 7, 8, 9) written exactly how it is written in the parentheses"

switch ($AccountType) {
  ("User") {
    $Users = Get-ADUser -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $true -and SamAccountName -notlike "*svc*" } -SearchBase $UserOU -Properties LastLogonDate | Select-Object @{ Name="Username"; Expression={$_.SamAccountName} }, Name, LastLogonDate, DistinguishedName
  }
  ("7") {
    $Users = Get-ADUser -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $true -and SamAccountName -notlike "*svc*" } -SearchBase $7AccountOU -Properties LastLogonDate | Select-Object @{ Name="Username"; Expression={$_.SamAccountName} }, Name, LastLogonDate, DistinguishedName
  }
  ("8") {
    $Users = Get-ADUser -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $true -and SamAccountName -notlike "*svc*" } -SearchBase $8AccountOU -Properties LastLogonDate | Select-Object @{ Name="Username"; Expression={$_.SamAccountName} }, Name, LastLogonDate, DistinguishedName
  }
  ("9") {
    $Users = Get-ADUser -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $true -and SamAccountName -notlike "*svc*" } -SearchBase $9AccountOU -Properties LastLogonDate | Select-Object @{ Name="Username"; Expression={$_.SamAccountName} }, Name, LastLogonDate, DistinguishedName
  }
}

#-------------------------------
# REPORTING
#-------------------------------
# Export results to CSV
$Users | Export-Csv $ResultFile -NoTypeInformation

#-------------------------------
# INACTIVE USER MANAGEMENT
#-------------------------------
# Below are two options to manage the inactive users that have been found. Either disable them, or delete them. Select the option that is most appropriate for your requirements:

# Disable Inactive Users
ForEach ($Item in $Users){
    $DistName = $Item.DistinguishedName
    Disable-ADAccount -Identity $DistName
    Get-ADUser -Filter { DistinguishedName -eq $DistName } | Select-Object @{ Name="Username"; Expression={$_.SamAccountName} }, Name, Enabled
  }
  
  # Delete Inactive Users
<#
$DeletedUsers = Get-ADUser -Filter { LastLogonDate -lt $DeletionDate -and SamAccountName -notlike "*svc*" } -Properties LastLogonDate | Select-Object @{ Name="Username"; Expression={$_.SamAccountName} }, Name, LastLogonDate, DistinguishedName

Foreach ($DeletedUser in $DeletedUsers) {
  Remove-ADUser -Identity $DeletedUser.DistinguishedName -Confirm:$false
    Write-Output "$($DeletedUser.Username) - Deleted"
}
#>
