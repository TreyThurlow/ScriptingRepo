All of the files in this directory, to include diskpart.txt and skip_EULA_unattend.xml, excluding the ReadMe.txt were created to be used in the SCCM imaging process.

Disable-IPv6 disables IPv6.

diskpart.txt wipes the drive.

Eject-Disk.ps1 will open the CD drive. The purpose of this script was when I had to use a WinPE disk to initiate the image process. 

Enable-RDP.ps1 enables the RDP function.

Remove-MicrosoftApps.ps1 will remove several Microsoft bloatware.

Remove-OneDrive.ps1 completely removes OneDrive for all users

SetIPBasedOnComputerName.ps1 - The purpose of this script is to import a CSV file with a list of computer names and their IPs. It will then set the IP, DNS servers, Subnet Mask, and Gateway per computer selection. The person running the script will be able to select what computer name they want. It will create a new file for the next script. It can be used in a DHCP environment if the set IP address command is removed.

SetOSDComputerName.ps1 uses the file created by the SetIPBasedOnComputerName.ps1 script to automatically assign a name to the computer.

skip_EULA_unattend.xml is loaded to skip through the EULA of Windows 10/11 and other features.

WindowsAdditionalStigs.ps1 sets certain STIG settings that Group Policy does not set.