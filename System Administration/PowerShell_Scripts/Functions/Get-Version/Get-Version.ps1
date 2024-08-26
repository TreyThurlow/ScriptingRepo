# Define a function to prompt for the version number, with parameter validation
<#
.SYNOPSIS
Prompts the user to enter a version number via a graphical form.

.DESCRIPTION
This function creates a Windows Form to prompt the user for a version number. The form contains a label, a text box for user input, and an "OK" button to submit the input. The function checks if the user clicks "OK" or cancels the prompt. If the user cancels, a warning is displayed, and the script exits. If the user submits the version number, it is returned as a string.

.EXAMPLE
$version = Get-Version
This example displays a form prompting the user to enter a version number, and stores the result in the `$version` variable.
#>
function Get-Version {
    Begin {
        Add-Type -AssemblyName System.Windows.Forms
        # Set up the Version Number Form.
        $versionForm = New-Object Windows.Forms.Form
        $versionForm.Width = 300
        $versionForm.Height = 150
        $versionForm.StartPosition = "CenterScreen"
        $versionForm.Text = "Enter Version Number"

        # Add a label to prompt for the version number.
        $versionLabel = New-Object Windows.Forms.Label
        $versionLabel.Text = "Please enter the version number:"
        $versionLabel.Location = New-Object System.Drawing.Point(10,40)
        $versionLabel.AutoSize = $true
        $versionForm.Controls.Add($versionLabel)

        # Add a text box to allow users to input the version number
        $versionBox = New-Object Windows.Forms.TextBox
        $versionBox.Location = New-Object System.Drawing.Point(10,70)
        $versionBox.Width = 260
        $versionBox.Text = $Version
        $versionForm.Controls.Add($versionBox)

        # Add a button to submit the version number and close the form
        $versionButton = New-Object Windows.Forms.Button
        $versionButton.Location = New-Object System.Drawing.Point(100,100)
        $versionButton.Text = "OK"
        $versionButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $versionForm.AcceptButton = $versionButton
        $versionForm.Controls.Add($versionButton)

        # Set the form to be always on top of other windows.
        $versionForm.Topmost = $true

        # Display the form and wait for user input.
        $result = $versionForm.ShowDialog()

        #If the user clicked OK, store the entered version number in the $version variable.
        if ($result -eq [System.Windows.Forms.DialogResult]::OK)
        {
            $Version = $versionBox.Text
        }
        else
        {
            # If the user cancelled, write a warning message and exit the script.
            Write-Warning "Version number prompt cancelled by user"
            exit
        }
    }
    End {
        # Return the validated version number string
        return $Version
    }
}