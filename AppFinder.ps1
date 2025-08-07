Add-Type -AssemblyName System.Windows.Forms

# Error handling function
function Show-Error {
    param([string]$errorMessage)
    [System.Windows.Forms.MessageBox]::Show($errorMessage, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

try {
    Write-Host "Creating GUI..."
    
    # Create a form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "App Finder"
    $form.Width = 400
    $form.Height = 400
    $form.StartPosition = "CenterScreen"

# Create a menu bar
$mainMenu = New-Object System.Windows.Forms.MainMenu

# Create a "Help" menu
$menuHelp = New-Object System.Windows.Forms.MenuItem
$menuHelp.Text = "Help"

# Create an "About" menu item
$menuAbout = New-Object System.Windows.Forms.MenuItem
$menuAbout.Text = "About"

# Handle the "About" menu item click event
$menuAbout.Add_Click({
    Start-Process "https://github.com/kkaminsk/AppFinder"
})

# Add the "About" menu item to the "Help" menu
$menuHelp.MenuItems.Add($menuAbout)

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

# Create a "Copy to Clipboard" button
$btnCopyToClipboard = New-Object System.Windows.Forms.Button
$btnCopyToClipboard.Text = "Copy"
$btnCopyToClipboard.Location = New-Object System.Drawing.Point(150, 60)
$btnCopyToClipboard.Add_Click({
    [System.Windows.Forms.Clipboard]::SetText($txtOutput.Text)
})

# Add the "Copy to Clipboard" button to the form
$form.Controls.Add($btnCopyToClipboard)

# Create a "Open in Notepad" button
$btnOpenInNotepad = New-Object System.Windows.Forms.Button
$btnOpenInNotepad.Text = "Notepad"
$btnOpenInNotepad.Location = New-Object System.Drawing.Point(250, 60)  # You might want to adjust the location as needed

$btnOpenInNotepad.Add_Click({
    # Create a temporary text file
    $tempFile = [System.IO.Path]::GetTempFileName()

    # Write the output to the file
    $txtOutput.Text | Out-File -FilePath $tempFile -Encoding utf8

    # Open the file in Notepad
    Start-Process -FilePath "notepad.exe" -ArgumentList $tempFile
})

# Add the "Open in Notepad" button to the form
$form.Controls.Add($btnOpenInNotepad)


# Define the search function
function Search {
    $targetAppName = $txtAppName.Text

    # Define the registry paths for uninstall information
    $registryPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    )

# Create an array to store the output
$outputArray = @()

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
            $outputArray += "DisplayName: $displayName"
            $outputArray += "UninstallString: $uninstallString"
            $outputArray += "Version: $version"
            $outputArray += "Publisher: $publisher"
            $outputArray += "InstallLocation: $installLocation"
            $outputArray += "---------------------------------------------------"
        }
    }
}

# Set the output text in the text box
$txtOutput.Text = $outputArray -join "`r`n"
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
Write-Host "Displaying GUI..."
$form.Add_Shown({$form.Activate()})

# Check if the script is being run from the command line
if ($Host.Name -eq "ConsoleHost") {
    Write-Host "Running in console mode. Performing test search..."
    $txtAppName.Text = "Notepad"
    Search
    Write-Host "Search results:"
    Write-Host $txtOutput.Text
    Write-Host "Test search completed. Exiting console mode."
    exit
}

[void]$form.ShowDialog()
}
catch {
    Show-Error "An error occurred: $_"
}
