# Use PowerShell 5
Add-Type -AssemblyName System.Windows.Forms

# Logging configuration
$script:logDirectory = Join-Path $PSScriptRoot "logs"
$script:logRetentionDays = 30
$script:logFilePath = ""
$script:loggingEnabled = $true

# Initialize logging
function Initialize-Logging {
    try {
        # Create logs directory if it doesn't exist
        if (-not (Test-Path $script:logDirectory)) {
            New-Item -Path $script:logDirectory -ItemType Directory -Force | Out-Null
        }
        
        # Set log file path with daily rotation
        $logFileName = "AppFinder-$(Get-Date -Format 'yyyy-MM-dd').log"
        $script:logFilePath = Join-Path $script:logDirectory $logFileName
        
        # Cleanup old log files (30 day retention)
        $cutoffDate = (Get-Date).AddDays(-$script:logRetentionDays)
        $oldLogs = Get-ChildItem -Path $script:logDirectory -Filter "AppFinder-*.log" -ErrorAction SilentlyContinue | 
            Where-Object { $_.LastWriteTime -lt $cutoffDate }
        
        if ($oldLogs) {
            $oldLogs | Remove-Item -Force -ErrorAction SilentlyContinue
            $cleanedCount = $oldLogs.Count
            if ($cleanedCount -gt 0) {
                Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [INFO] Cleaned up $cleanedCount old log files"
            }
        }
    }
    catch {
        $script:loggingEnabled = $false
        Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [WARNING] Failed to initialize file logging: $($_.Exception.Message)"
        Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [WARNING] Continuing with console-only logging"
    }
}

# Error handling function
function Show-Error {
    param([string]$errorMessage)
    [System.Windows.Forms.MessageBox]::Show($errorMessage, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

# Enhanced logging function with file and console output
function Write-Log {
    param(
        [string]$message,
        [string]$level = "INFO"  # INFO, WARNING, ERROR
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry = "[$timestamp] [$level] $message"
    
    # Always write to console
    Write-Host $logEntry
    
    # Write to file if logging is enabled
    if ($script:loggingEnabled -and $script:logFilePath) {
        try {
            Add-Content -Path $script:logFilePath -Value $logEntry -ErrorAction Stop
        }
        catch {
            # Suppress file write errors to avoid disrupting application
            # Only disable logging on first failure
            if ($script:loggingEnabled) {
                $script:loggingEnabled = $false
                Write-Host "[$timestamp] [WARNING] Failed to write to log file: $($_.Exception.Message)"
                Write-Host "[$timestamp] [WARNING] File logging disabled, continuing with console-only logging"
            }
        }
    }
}

# Initialize logging system
Initialize-Logging

try {
    Write-Log "Script started"
    Write-Log "PowerShell version: $($PSVersionTable.PSVersion.ToString())"
    Write-Log "Creating GUI..."
    
    # Create a form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "App Finder"
    $form.Width = 550
    $form.Height = 450
    $form.StartPosition = "CenterScreen"

# Create a menu strip
$menuStrip = New-Object System.Windows.Forms.MenuStrip

# Create "Copy to Clipboard" menu item
$menuCopyToClipboard = New-Object System.Windows.Forms.ToolStripMenuItem
$menuCopyToClipboard.Text = "Copy to Clipboard"
$menuCopyToClipboard.Add_Click({
    Write-Log "Copy to clipboard requested (menu)"
    if (-not [string]::IsNullOrWhiteSpace($txtOutput.Text)) {
        [System.Windows.Forms.Clipboard]::SetText($txtOutput.Text)
        Write-Log "Copy to clipboard executed successfully"
    } else {
        Write-Log "Copy to clipboard failed: No content to copy" "WARNING"
        [System.Windows.Forms.MessageBox]::Show("No content to copy.", "Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
})
$menuStrip.Items.Add($menuCopyToClipboard) | Out-Null

# Create "Open in Notepad" menu item
$menuOpenInNotepad = New-Object System.Windows.Forms.ToolStripMenuItem
$menuOpenInNotepad.Text = "Open in Notepad"
$menuOpenInNotepad.Add_Click({
    Write-Log "Open in Notepad requested (menu)"
    # Create a temporary text file
    $tempFile = [System.IO.Path]::GetTempFileName()

    # Write the output to the file
    $txtOutput.Text | Out-File -FilePath $tempFile -Encoding utf8

    # Open the file in Notepad
    Start-Process -FilePath "notepad.exe" -ArgumentList $tempFile
    Write-Log "Opened in Notepad: $tempFile"
})
$menuStrip.Items.Add($menuOpenInNotepad) | Out-Null

# Create "Clear" menu item
$menuClearTextbox = New-Object System.Windows.Forms.ToolStripMenuItem
$menuClearTextbox.Text = "Clear"
$menuClearTextbox.Add_Click({
    Write-Log "Output cleared (menu)"
    $txtOutput.Text = ""
})
$menuStrip.Items.Add($menuClearTextbox) | Out-Null

# Create "Help" menu
$menuHelp = New-Object System.Windows.Forms.ToolStripMenuItem
$menuHelp.Text = "Help"

# Create "About" submenu item
$menuAbout = New-Object System.Windows.Forms.ToolStripMenuItem
$menuAbout.Text = "About"
$menuAbout.Add_Click({
    Write-Log "About menu clicked - opening GitHub repository"
    Start-Process "https://github.com/kkaminsk/AppFinder"
})
$menuHelp.DropDownItems.Add($menuAbout) | Out-Null
$menuStrip.Items.Add($menuHelp) | Out-Null

# Add the menu strip to the form
$form.Controls.Add($menuStrip)

# Create a label and textbox for the application name
$lblAppName = New-Object System.Windows.Forms.Label
$lblAppName.Text = "Application Name:"
$lblAppName.Location = New-Object System.Drawing.Point(20, 45)
$lblAppName.AutoSize = $true

$txtAppName = New-Object System.Windows.Forms.TextBox
$txtAppName.Location = New-Object System.Drawing.Point(150, 45)
$txtAppName.Width = 200

# Create a button for searching
$btnSearch = New-Object System.Windows.Forms.Button
$btnSearch.Text = "Search"
$btnSearch.Location = New-Object System.Drawing.Point(20, 85)
$btnSearch.Width = 100

# Create a text box for displaying the output
$txtOutput = New-Object System.Windows.Forms.TextBox
$txtOutput.Multiline = $true
$txtOutput.ScrollBars = "Vertical"
$txtOutput.Location = New-Object System.Drawing.Point(20, 125)
$txtOutput.Width = 510
$txtOutput.Height = 215
$txtOutput.ReadOnly = $true

# Create a "Copy to Clipboard" button
$btnCopyToClipboard = New-Object System.Windows.Forms.Button
$btnCopyToClipboard.Text = "Copy"
$btnCopyToClipboard.Location = New-Object System.Drawing.Point(130, 85)
$btnCopyToClipboard.Width = 100
$btnCopyToClipboard.Add_Click({
    Write-Log "Copy to clipboard requested (button)"
    if (-not [string]::IsNullOrWhiteSpace($txtOutput.Text)) {
        [System.Windows.Forms.Clipboard]::SetText($txtOutput.Text)
        Write-Log "Copy to clipboard executed successfully"
    } else {
        Write-Log "Copy to clipboard failed: No content to copy" "WARNING"
        [System.Windows.Forms.MessageBox]::Show("No content to copy.", "Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
})

# Add the "Copy to Clipboard" button to the form
$form.Controls.Add($btnCopyToClipboard)

# Create a "Open in Notepad" button
$btnOpenInNotepad = New-Object System.Windows.Forms.Button
$btnOpenInNotepad.Text = "Notepad"
$btnOpenInNotepad.Location = New-Object System.Drawing.Point(240, 85)
$btnOpenInNotepad.Width = 100

$btnOpenInNotepad.Add_Click({
    Write-Log "Open in Notepad requested (button)"
    # Create a temporary text file
    $tempFile = [System.IO.Path]::GetTempFileName()

    # Write the output to the file
    $txtOutput.Text | Out-File -FilePath $tempFile -Encoding utf8

    # Open the file in Notepad
    Start-Process -FilePath "notepad.exe" -ArgumentList $tempFile
    Write-Log "Opened in Notepad: $tempFile"
})

# Add the "Open in Notepad" button to the form
$form.Controls.Add($btnOpenInNotepad)

# Create an "Uninstall" button
$btnUninstall = New-Object System.Windows.Forms.Button
$btnUninstall.Text = "Uninstall"
$btnUninstall.Location = New-Object System.Drawing.Point(400, 85)
$btnUninstall.Width = 100
$btnUninstall.Enabled = $false

$btnUninstall.Add_Click({
    Write-Log "Uninstall button clicked"
    Uninstall
})

# Add the "Uninstall" button to the form
$form.Controls.Add($btnUninstall)

# Create a progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 375)
$progressBar.Width = 510
$progressBar.Height = 20
$progressBar.Style = 'Continuous'
$progressBar.Visible = $false

$form.Controls.Add($progressBar)

# Global variable to store uninstall information
$script:uninstallInfo = @()

# Function to handle the uninstall process
function Uninstall {
    if ($script:uninstallInfo.Count -eq 0) {
        Write-Log "Uninstall failed: No uninstall information available" "WARNING"
        [System.Windows.Forms.MessageBox]::Show("No uninstall information available.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    if ($script:uninstallInfo.Count -eq 1) {
        $selectedUninstall = $script:uninstallInfo[0]
        Write-Log "Single application selected for uninstall: $($selectedUninstall.DisplayName)"
    } else {
        Write-Log "Multiple applications available, opening selection dialog"
        $selectedUninstall = $script:uninstallInfo | Select-Object @{Name='Application';Expression={$_.DisplayName}}, @{Name='UninstallString';Expression={$_.UninstallString}} | Out-GridView -Title "Select an Application to Uninstall" -OutputMode Single
    }

    if ($selectedUninstall) {
        try {
            $appName = if ($selectedUninstall.DisplayName) { $selectedUninstall.DisplayName } else { $selectedUninstall.Application }
            $uninstallString = $selectedUninstall.UninstallString
            Write-Log "Uninstall operation started: $appName" "WARNING"
            Write-Log "Executing uninstall string: $uninstallString"
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstallString" -Wait
            Write-Log "Uninstall completed: $appName"
            [System.Windows.Forms.MessageBox]::Show("Uninstall process completed for $appName. Please verify if the application was successfully removed.", "Uninstall Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } catch {
            $errorMessage = $_.Exception.Message
            $appName = if ($selectedUninstall.DisplayName) { $selectedUninstall.DisplayName } else { $selectedUninstall.Application }
            Write-Log "Uninstall failed: $appName - $errorMessage" "ERROR"
            [System.Windows.Forms.MessageBox]::Show("An error occurred during the uninstall process: $errorMessage", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    } else {
        Write-Log "Uninstall cancelled: No application selected"
    }
}

# Define the search function
function Search {
    $script:uninstallInfo = @()
    $btnUninstall.Enabled = $false
    $targetAppName = $txtAppName.Text
    
    Write-Log "Search initiated: term='$targetAppName'"

    # Show and reset progress bar
    $progressBar.Visible = $true
    $progressBar.Value = 0
    Write-Log "Search progress started"

    # Define the registry paths for uninstall information
    $registryPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    # Set progress bar maximum value
    $progressBar.Maximum = $registryPaths.Count

# Create an array to store the output
$outputArray = @()

# Loop through each registry path and retrieve the list of subkeys
foreach ($path in $registryPaths) {
    $uninstallKeys = Get-ChildItem -Path $path -ErrorAction SilentlyContinue

    # Skip if the registry path doesn't exist
    if (-not $uninstallKeys) {
        Write-Log "Registry path inaccessible: $path" "WARNING"
        # Increment progress even if path doesn't exist
        $progressBar.Value++
        $form.Refresh()
        continue
    }
    
    Write-Log "Scanning registry path: $path"

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
            
            if ($uninstallString) {
                $script:uninstallInfo += [PSCustomObject]@{
                    DisplayName = $displayName
                    UninstallString = $uninstallString
                }
            }
        }
    }
    
    # Increment progress bar after processing each registry path
    $progressBar.Value++
    $form.Refresh()
}

# Set the output text in the text box
$txtOutput.Text = $outputArray -join "`r`n"

# Hide progress bar when complete
$progressBar.Visible = $false
Write-Log "Search progress completed"

# Log search results
$resultsCount = $script:uninstallInfo.Count
if ($resultsCount -gt 0) {
    Write-Log "Search completed: $resultsCount result(s) found"
} else {
    Write-Log "Search completed: No results found"
}

# Enable or disable the Uninstall button based on search results
$btnUninstall.Enabled = $script:uninstallInfo.Count -gt 0
}

# Add the search function to the button click event
$btnSearch.Add_Click({ 
    Write-Log "Search button clicked"
    Search 
})

# Handle the Enter key press event in the text box
$txtAppName.Add_KeyDown({
    param($sender, $e)
    if ($e.KeyCode -eq "Enter") {
        Write-Log "Search triggered via Enter key"
        Search
    }
})

# Add the controls to the form
$form.Controls.Add($lblAppName)
$form.Controls.Add($txtAppName)
$form.Controls.Add($btnSearch)
$form.Controls.Add($txtOutput)

# Show the form
Write-Log "GUI initialized successfully"
Write-Log "Displaying GUI..."
$form.Add_Shown({$form.Activate()})

# Check if the script is being run from the command line
if ($Host.Name -eq "ConsoleHost") {
    Write-Log "Console mode detected"
    Write-Log "Running in console mode."
    $consoleAppName = Read-Host "Enter the application name to search for"
    Write-Log "Searching for: $consoleAppName"
    $txtAppName.Text = $consoleAppName
    Search
    Write-Log "Search results:"
    Write-Log $txtOutput.Text
    Write-Log "Console search completed. Continuing to display GUI."
} else {
    Write-Log "GUI mode detected"
}

Write-Log "Showing dialog"
[void]$form.ShowDialog()
Write-Log "Dialog closed"
}
catch {
    $errorMessage = $_.Exception.Message
    Write-Log "Error occurred: $errorMessage" "ERROR"
    Show-Error "An error occurred: $errorMessage"
}
finally {
    Write-Log "Script ended"
}
