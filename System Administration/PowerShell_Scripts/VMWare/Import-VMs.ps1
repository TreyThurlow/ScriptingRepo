<#
.SYNOPSIS
    Imports Virtual Machines from OVA/OVF files to an ESXi server.

.DESCRIPTION
    This script extracts OVA files into OVF, VMDK, and MF files, connects to an ESXi server, and imports the Virtual Machines.
    It requires user input for the ESXi server name, file path of the OVA files, disk format, datastore, and VM names.

.EXAMPLE
    # Run the script to import VMs
    .\Import-VMs.ps1

    # Example usage:
    # Enter the ESXi Server name that you want to store the VMs on: ESXiServer01
    # Enter the File Path that the OVA files are stored on: C:\OVAFiles
    # Do you want Thick or Thin provisioned? Thin
    # What datastore does this VM need to go to? Datastore01
    # What will the name of the VM be? VM01
    # Importing VM01 to Datastore01 on ESXiServer01.
#>
#>


#This first section of the script contains the variables that are "static" throughout the script, meaning they won't change. such as file location of ESXi Server

$ServerName = Read-Host "Enter the ESXi Server name that you want to store the VMs on."
$FilePath = Read-Host "Enter the File Path that the OVA files are stored on."
$DiskFormat = Read-Host "Do you want Thick or Thin provisioned?"

#The below section will extract the OVA File into OVF, VMDK, and MF files. These files are needed by the next part of the script to import the Virtual Machines. Comment out the below foreach loop if you do not have any OVA files and only have OVF files.


foreach ($OVA in (Get-ChildItem -Path "$FilePath\*.ova")) {
    & "C:\Program Files\VMware\VMware OVF Tool\ovftool.exe" $OVA "$FilePath\$OVA"
}

#Connects to the ESXi Server that was entered earlier


Connect-VIServer $ServerName

#This next foreach loop is the actual process of importing the Virtual Machines. It requires user input to declare the name of each Virtual Machine and the datastore that the virutal machine will go to.

$ESXiHost = Get-VMHost -Name $ServerName
foreach ($OVF in (Get-ChildItem -Path "$FilePath\*.ovf")) {
    $Datastore = Read-Host "What datastore does this VM need to go to?"
    $VMDatastore = Get-Datastore -Name $Datastore
    $VMName = Read-Host "What will the name of the VM be?"
    Write-Host "Importing $VMName to $Datastore on $ServerName." -ForegroundColor Green -BackgroundColor Black
    Import-VApp -Source $OVF -VMHost $ESXiHost -Datastore $VMDatastore -DiskstorageFormat $DiskFormat -RunAsync -Name $VMName -Force
}

