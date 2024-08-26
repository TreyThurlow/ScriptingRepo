<#
.SYNOPSIS
    Displays a form to select and set the default printer on a specified print server.

.DESCRIPTION
    This script retrieves a list of printers from a specified print server and displays them in a Windows form. 
    The user can select a printer from the list and set it as the default printer on the print server.

.EXAMPLE
    .\Add-Printer.ps1
    Retrieves printers from PRINTSERVER01, displays them in a form, and allows the user to set the selected printer as the default.
#>

$printServer = "PRINTSERVER01"

# Get a list of the printers installed on the print server
$printers = Get-Printer -ComputerName $printServer

# Create the Windows form
Add-Type -AssemblyName System.Windows.Forms
$form = New-Object System.Windows.Forms.Form
$form.Text = "Printer Selector"
$form.Size = New-Object System.Drawing.Size(350,300)
$form.StartPosition = "CenterScreen"
$form.Topmost = $true

$printerListBox = New-Object System.Windows.Forms.ListBox
$printerListBox.Location = New-Object System.Drawing.Point(50,50)
$printerListBox.Size = New-Object System.Drawing.Size(250,150)
$printerListBox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",10)
$printerListBox.SelectionMode = "One"
$printerListBox.Items.AddRange($printers.Name)

$form.Controls.Add($printerListBox)

$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(125,220)
$button.Size = New-Object System.Drawing.Size(100,30)
$button.Text = "Set Default Printer"
$button.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",10)
$button.Add_Click({
    $selectedPrinter = $printerListBox.SelectedItem

    # Set the selected printer as the default printer
    if($selectedPrinter) {
        Set-Printer -Name $selectedPrinter -ComputerName $printServer -Force -Default
    }
})

$form.Controls.Add($button)

# Display the form to the user
[void] $form.ShowDialog()