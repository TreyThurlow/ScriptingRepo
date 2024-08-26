# Load the required assemblies for WPF windows
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# Function to show WPF message box pop-up
function Show-MsgBox ($Message, $Title, $Buttons, $Icon) {
    return [System.Windows.MessageBox]::Show($Message, $Title, $Buttons, $Icon)
}

# Function to create new WPF window
function New-Window ($Title, $Width, $Height) {
    $window = New-Object System.Windows.Window
    $window.Title = $Title
    $window.Width = $Width
    $window.Height = $Height
    $window.WindowStartupLocation = "CenterScreen"
    return $window
}

# Function to create new WPF button
function New-Button ($Content, $IsDefault, $Height, $Width) {
    $button = New-Object System.Windows.Controls.Button
    $button.Content = $Content
    $button.IsDefault = $IsDefault
    $button.Height = $Height
    $button.Width = $Width
    return $button
}

# Set the HTML file path
$htmlFilePath = "C:\Users\trey.thurlow\OneDrive - Defense Information Systems Agency\Documents\Scripting\HTML\Phantom\index.html"

# Define the sections and their IDs
$sections = @{
    id1 = "server1"
    id2 = "server2"
    id3 = "server3"
    id4 = "server4"
    id5 = "recap"
}

# Loop through each section in order
foreach ($section in ($sections.GetEnumerator() | Sort-Object {[int]($_.Name -replace '\D')})) {

    # Ask user if they want to edit this section using WPF popup window
    $msgBoxInput = Show-MsgBox -Message "Do you want to edit $($section.Value) ($($section.Name))?" -Title "Edit Section" -Buttons YesNo -Icon Question
    if ($msgBoxInput -eq [System.Windows.Forms.DialogResult]::Yes) {

        # Prompt user for new text for this section using WPF textbox
        $newText = ""
        $textWindow = New-Window -Title "Edit $($section.Value)" -Width 300 -Height 150
        $textBox = New-Object System.Windows.Controls.TextBox
        $textBox.Height = 100
        $textBox.TextWrapping = "Wrap"
        $textBox.AcceptsReturn = $true
        $okButton = New-Button -Content "OK" -IsDefault $True -Height 30 -Width 70
        $okButton.Add_Click({
            $newText = $textBox.Text
            $textWindow.DialogResult = [System.Windows.Forms.DialogResult]::OK
        })
        $cancelButton = New-Button -Content "Cancel" -IsCancel $True -Height 30 -Width 70
        $cancelButton.Add_Click({
            $textWindow.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
            $textWindow.Close()
        })
        $dockPanel = New-Object System.Windows.Controls.DockPanel
        $dockPanel.Children.Add($okButton)
        $dockPanel.Children.Add($cancelButton)
        [System.Windows.Controls.DockPanel]::SetDock($okButton, "Right")
        [System.Windows.Controls.DockPanel]::SetDock($cancelButton, "Right")
        $textWindow.Content = $dockPanel
        $dockPanel.Children.Add($textBox)
        [System.Windows.Controls.DockPanel]::SetDock($textBox, [System.Windows.Controls.Dock]::Top)
        $dockPanel.LastChildFill = $true
        $result = $textWindow.ShowDialog()
        if ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
            continue  # Skip to next section
        }

        # Replace text in this section of HTML file
        (Get-Content $htmlFilePath) |
        ForEach-Object {
            if ($_ -match "<p id=`"$($section.Value)`">") {
                $_ -replace "(?<=<p id=`"$($section.Value)`">).*?(?=</p>)", $newText
            } else {
                $_
            }
        } |
        Set-Content $htmlFilePath
    }
}

# Restart the website in IIS using WPF popup
$msgBoxInput = Show-MsgBox -Message "Do you want to restart the website in IIS?" -Title "Restart Website" -Buttons YesNo -Icon Question
if ($msgBoxInput -eq [System.Windows.Forms.DialogResult]::Yes) {
    $websiteName = "My Website"
    $webAppPool = Get-WebAppPoolState -Name $websiteName | Select-Object -ExpandProperty value
    Stop-WebAppPool $webAppPool
    Start-WebAppPool $webAppPool
    Restart-WebItem "IIS:\Sites\$websiteName"
}