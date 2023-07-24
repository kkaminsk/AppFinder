## minor tweaks to UI and Progress bar
Add-Type -AssemblyName System.Windows.Forms

# Create a form
$form = New-Object System.Windows.Forms.Form
$form.Text = "App Finder"
$form.Width = 400
$form.Height = 450  # Adjusted form height to accommodate progress bar
$form.StartPosition = "CenterScreen"

# Create a menu bar
$mainMenu = New-Object System.Windows.Forms.MainMenu

# Create a "Help" menu
$menuHelp = New-Object System.Windows.Forms.MenuItem
$menuHelp.Text = "Help"

# Create an "About" menu item
$menuAbout = New-Object System.Windows.Forms.MenuItem
$menuAbout.Text = "About"
$menuAbout.Add_Click({
    Start-Process "https://github.com/kkaminsk/AppFinder"
})

# Add the "About" menu item to the "Help" menu
$menuHelp.MenuItems.Add($menuAbout)

# Create a "Copy to Clipboard" menu item
$menuCopyToClipboard = New-Object System.Windows.Forms.MenuItem
$menuCopyToClipboard.Text = "Copy to Clipboard"
$menuCopyToClipboard.Add_Click({
    [System.Windows.Forms.Clipboard]::SetText($txtOutput.Text)
})

# Add the "Copy to Clipboard" menu item to the main menu
$mainMenu.MenuItems.Add($menuCopyToClipboard)

# Create an "Open in Notepad" menu item
$menuOpenInNotepad = New-Object System.Windows.Forms.MenuItem
$menuOpenInNotepad.Text = "Open in Notepad"
$menuOpenInNotepad.Add_Click({
    # Create a temporary text file
    $tempFile = [System.IO.Path]::GetTempFileName()

    # Write the output to the file
    $txtOutput.Text | Out-File -FilePath $tempFile -Encoding utf8

    # Open the file in Notepad
    Start-Process -FilePath "notepad.exe" -ArgumentList $tempFile
})

# Add the "Open in Notepad" menu item to the main menu
$mainMenu.MenuItems.Add($menuOpenInNotepad)

# Create a "Clear Textbox" menu item
$menuClearTextbox = New-Object System.Windows.Forms.MenuItem
$menuClearTextbox.Text = "Clear"
$menuClearTextbox.Add_Click({
    $txtOutput.Text = ""
})

# Add the "Clear Textbox" menu item to the main menu
$mainMenu.MenuItems.Add($menuClearTextbox)

# Add the "Help" menu to the main menu
$mainMenu.MenuItems.Add($menuHelp)

# Set the form's menu to the main menu
$form.Menu = $mainMenu

# Create a label and textbox for the application name
$lblAppName = New-Object System.Windows.Forms.Label
$lblAppName.Text = "Application Name:"
$lblAppName.Location = New-Object System.Drawing.Point(20, 20)
$lblAppName.AutoSize = $true

$txtAppName = New-Object System.Windows.Forms.TextBox
$txtAppName.Location = New-Object System.Drawing.Point(150, 20)
$txtAppName.Width = 200

# Create a button for searching
$btnSearch = New-Object System.Windows.Forms.Button
$btnSearch.Text = "Search"
$btnSearch.Location = New-Object System.Drawing.Point(50, 60)

# Create a text box for displaying the output
$txtOutput = New-Object System.Windows.Forms.TextBox
$txtOutput.Multiline = $true
$txtOutput.ScrollBars = "Vertical"
$txtOutput.Location = New-Object System.Drawing.Point(20, 100)
$txtOutput.Width = 360
$txtOutput.Height = 240
$txtOutput.ReadOnly = $true

# Create a progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 346)  # Adjusted the Y-axis location
$progressBar.Width = 360
$progressBar.Height = 20
$progressBar.Style = 'Continuous'

$form.Controls.Add($progressBar)

# Define the search function
function Search {
    $targetAppName = $txtAppName.Text

    # Define the registry paths for uninstall information
    $registryPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    # Set progress bar maximum value
    $progressBar.Maximum = $registryPaths.Count
    $progressBar.Value = 0

    # Create a string builder to store the output
    $output = New-Object System.Text.StringBuilder

    # Loop through each registry path and retrieve the list of subkeys
    foreach ($path in $registryPaths) {
        $uninstallKeys = Get-ChildItem -Path $path -ErrorAction SilentlyContinue

        # Skip if the registry path doesn't exist
        if (-not $uninstallKeys) {
            continue
        }

        # Loop through each uninstall key and append the properties of the target application to the output
        foreach ($key in $uninstallKeys) {
            $keyPath = Join-Path -Path $path -ChildPath $key.PSChildName

            $displayName = (Get-ItemProperty -Path $keyPath -Name "DisplayName" -ErrorAction SilentlyContinue).DisplayName
            $uninstallString = (Get-ItemProperty -Path $keyPath -Name "UninstallString" -ErrorAction SilentlyContinue).UninstallString
            $version = (Get-ItemProperty -Path $keyPath -Name "DisplayVersion" -ErrorAction SilentlyContinue).DisplayVersion
            $publisher = (Get-ItemProperty -Path $keyPath -Name "Publisher" -ErrorAction SilentlyContinue).Publisher
            $installLocation = (Get-ItemProperty -Path $keyPath -Name "InstallLocation" -ErrorAction SilentlyContinue).InstallLocation

            if ($displayName -match $targetAppName) {
                $output.AppendLine("DisplayName: $displayName")
                $output.AppendLine("UninstallString: $uninstallString")
                $output.AppendLine("Version: $version")
                $output.AppendLine("Publisher: $publisher")
                $output.AppendLine("InstallLocation: $installLocation")
                $output.AppendLine("---------------------------------------------------")
            }
        }

        # Increase the value of progress bar
        $progressBar.Value++
    }

    # Set the output text in the text box
    $txtOutput.Text = $output.ToString()

    # Reset progress bar
    $progressBar.Value = 0
}

# Add the search function to the button click event
$btnSearch.Add_Click({ Search })

# Handle the Enter key press event in the text box
$txtAppName.Add_KeyDown({
    param($sender, $e)
    if ($e.KeyCode -eq "Enter") {
        Search
    }
})

# Add the controls to the form
$form.Controls.Add($lblAppName)
$form.Controls.Add($txtAppName)
$form.Controls.Add($btnSearch)
$form.Controls.Add($txtOutput)

# Show the form
$form.ShowDialog() | Out-Null
