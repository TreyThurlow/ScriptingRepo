<#
.SYNOPSIS
    Creates a new Active Directory user and adds them to a specified security group.

.DESCRIPTION
    This script creates a Windows Form to prompt the user for details such as display name, username, password, and security group. It then creates a new Active Directory user with the provided details and adds the user to the specified security group.

.EXAMPLE
    PS C:\> .\Create-ADUser.ps1

    This example runs the script, opens a form for user input, and creates a new AD user with the provided details.
#>

Add-Type -AssemblyName System.Windows.Forms

# Define the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Create AD User"
$form.Size = New-Object System.Drawing.Size(300,350)
$form.StartPosition = "CenterScreen"

# Define form components
$nameLabel = New-Object System.Windows.Forms.Label
$nameLabel.Location = New-Object System.Drawing.Point(10,20)
$nameLabel.Size = New-Object System.Drawing.Size(120,20)
$nameLabel.Text = "Display Name:"
$form.Controls.Add($nameLabel)

$nameBox = New-Object System.Windows.Forms.TextBox
$nameBox.Location = New-Object System.Drawing.Point(140,20)
$nameBox.Size = New-Object System.Drawing.Size(140,20)
$form.Controls.Add($nameBox)

$usernameLabel = New-Object System.Windows.Forms.Label
$usernameLabel.Location = New-Object System.Drawing.Point(10,50)
$usernameLabel.Size = New-Object System.Drawing.Size(120,20)
$usernameLabel.Text = "Username:"
$form.Controls.Add($usernameLabel)

$usernameBox = New-Object System.Windows.Forms.TextBox
$usernameBox.Location = New-Object System.Drawing.Point(140,50)
$usernameBox.Size = New-Object System.Drawing.Size(140,20)
$form.Controls.Add($usernameBox)

$passwordLabel = New-Object System.Windows.Forms.Label
$passwordLabel.Location = New-Object System.Drawing.Point(10,80)
$passwordLabel.Size = New-Object System.Drawing.Size(120,20)
$passwordLabel.Text = "Password:"
$form.Controls.Add($passwordLabel)

$passwordBox = New-Object System.Windows.Forms.TextBox
$passwordBox.Location = New-Object System.Drawing.Point(140,80)
$passwordBox.Size = New-Object System.Drawing.Size(140,20)
$passwordBox.PasswordChar = '*'
$form.Controls.Add($passwordBox)

$groupLabel = New-Object System.Windows.Forms.Label
$groupLabel.Location = New-Object System.Drawing.Point(10,110)
$groupLabel.Size = New-Object System.Drawing.Size(120,20)
$groupLabel.Text = "Security Group:"
$form.Controls.Add($groupLabel)

$groupDropdown = New-Object System.Windows.Forms.ComboBox
$groupDropdown.Location = New-Object System.Drawing.Point(140,110)
$groupDropdown.Size = New-Object System.Drawing.Size(140,20)
$groupNames = Get-ADGroup -Filter * | Select-Object -ExpandProperty Name
$groupDropdown.Items.AddRange($groupNames)
$form.Controls.Add($groupDropdown)

$createButton = New-Object System.Windows.Forms.Button
$createButton.Location = New-Object System.Drawing.Point(100,150)
$createButton.Size = New-Object System.Drawing.Size(100,25)
$createButton.Text = "Create User"
$createButton.Add_Click({
    # Create new user
    $name = $nameBox.Text
    $username = $usernameBox.Text
    $password = $passwordBox.Text
    $groupName = $groupDropdown.SelectedItem

    # Get the security group
    $group = Get-ADGroup -Filter "Name -eq '$groupName'"
    $groupDN = $group.DistinguishedName

    # Define AD user properties
    $userProperties = @{
        GivenName = $name.Split(' ')[0]
        Surname = $name.Split(' ')[1]
        DisplayName = $name
        UserPrincipalName = $username + "@yourdomain.com"
        AccountPassword = ConvertTo-SecureString -String $password -AsPlainText -Force
        Enabled = $true
        Path = "OU=NewUsers,DC=yourdomain,DC=com"
    }

    # Create new AD user
    New-ADUser @userProperties -Verbose

    # Add user to the specified security group
    Add-ADGroupMember -Identity $groupDN -Members $username

    # Display success message
    [System.Windows.Forms.MessageBox]::Show('User created and added to security group successfully.')
})
$form.Controls.Add($createButton)

$form.ShowDialog() | Out-Null