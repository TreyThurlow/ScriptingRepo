<#
.SYNOPSIS
    Changes the password of a local user on a list of computers

.DESCRIPTION
    This script reads a list of computer names from a specified file, updates the password of a specified local user for each computer, 

.EXAMPLE
    .\Change-LocalPassword.ps1
    Prompts for the name of the local user and new password for the computers listed in the specified file.
#>

#Variable containing Computer List based on location and computer type.
$Computers = Get-Content Path\To\File

#This command specifies the local account
$LocalAccount = Read-Host "Type the name of the local account that you are wanting to change the password for."

#This command is where you enter the password of the local account
$Password = Read-Host -AsSecureString

#Performs the command per alive computer.
Foreach ($Computer in $Computers) {
    Invoke-Command -ComputerName $Computer -ScriptBlock { 
        #Command to actually change the password
        Set-LocalUser $using:LocalAccount -Password $using:Password -UserMayChangePassword 1
    }
}

