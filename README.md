# AppFinder

A PowerShell-based Windows application finder and manager that allows you to easily search for installed applications and retrieve detailed information such as Uninstall String, Version, Publisher, and Install Location without manually searching through the Windows registry.

Originally written by Marin Alexandruradu. This is a fork by Kevin Kaminski with enhanced functionality and improved user interface.

## Requirements

- Windows operating system
- PowerShell 5.1 or later
- Administrator privileges may be required for some uninstall operations

## Features

### Core Functionality
- **GUI-based application search** with intuitive Windows Forms interface
- **Console mode** for quick command-line searches
- **Registry-based search** across multiple Windows registry hives
- **Pattern matching** search (supports partial application names)
- **Real-time logging** with timestamps for debugging and monitoring

### User Interface Features
- **Modern menu bar** with Copy to Clipboard, Open in Notepad, Clear, and Help menus
- **Progress bar** providing visual feedback during registry scanning operations
- **Search input** with Enter key support for quick searches
- **Multi-line output display** with vertical scrolling
- **Copy to Clipboard** functionality (menu and button) with validation to prevent errors on empty results
- **Open in Notepad** feature (menu and button) for external viewing and editing of results
- **Clear function** to quickly reset the output display
- **One-click Uninstall** with intelligent selection for multiple uninstall options
- **Dual access methods** - most features accessible via both menu bar and buttons

### Advanced Capabilities
- **Multiple registry path scanning**:
  - `HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall` (64-bit applications)
  - `HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall` (32-bit applications on 64-bit systems)
  - `HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall` (user-specific installations)
- **Comprehensive error handling** with user-friendly error messages
- **Automatic uninstall string validation** and execution
- **GridView selection** for multiple uninstall options
- **Temporary file management** for Notepad integration

## Usage

### GUI Mode (Recommended)

1. **Launch the application**:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\AppFinder.ps1
   ```

2. **Search for applications**:
   - Enter the application name or partial name in the "Application Name" text box
   - Click the "Search" button or press Enter to perform the search
   - Results will display in the output area below

3. **View and manage results**:
   - **Copy**: Click the button or use menu → Copy to Clipboard to copy results
   - **Notepad**: Click the button or use menu → Open in Notepad to view results externally
   - **Clear**: Use menu → Clear to reset the output display
   - **Uninstall**: Click to uninstall the found application(s)
   - **Progress Bar**: Watch the progress bar at the bottom during searches

4. **Access help**:
   - Use the Help menu → About to visit the GitHub repository

### Console Mode

When run from a PowerShell console, the script will:
1. Prompt for an application name to search
2. Display results in the console
3. Continue to launch the GUI for additional operations

```powershell
# Example console usage
PS> .\AppFinder.ps1
Enter the application name to search for: chrome
# Results displayed in console, then GUI launches
```

### Uninstall Functionality

The uninstall feature provides intelligent handling:
- **Single application**: Automatically proceeds with uninstallation
- **Multiple applications**: Opens a GridView selection dialog
- **Error handling**: Displays detailed error messages if uninstallation fails
- **Confirmation**: Shows completion status after uninstall attempt

## Information Retrieved

For each matching application, AppFinder displays:
- **DisplayName**: The application's display name
- **UninstallString**: Command used to uninstall the application
- **Version**: Application version number
- **Publisher**: Software publisher/developer
- **InstallLocation**: Installation directory path

## Technical Details

### Architecture
- Built using modern .NET Windows Forms API (MenuStrip, ToolStripMenuItem)
- Implements comprehensive error handling with try-catch blocks and input validation
- Uses PowerShell's registry access capabilities
- Real-time UI updates with progress feedback
- Null-safe clipboard operations to prevent exceptions

### Logging System
The script includes comprehensive file-based and console logging:

**Log Files:**
- Location: `.\logs\` directory (relative to script)
- Format: `AppFinder-YYYY-MM-DD.log` (daily rotation)
- Retention: 30 days (automatic cleanup on startup)
- Structure: `[YYYY-MM-DD HH:MM:SS] [LEVEL] Message`

**Log Levels:**
- **INFO**: Normal operations (searches, button clicks, menu selections)
- **WARNING**: Non-critical issues (empty searches, inaccessible registry paths, cancelled operations)
- **ERROR**: Critical failures (uninstall errors, unhandled exceptions)

**What Gets Logged:**
- Application lifecycle (startup, shutdown, mode detection)
- All user interactions (searches, clipboard operations, uninstalls)
- Registry scanning operations and results
- Progress bar state changes
- Error conditions and exceptions
- Uninstall operations with application names and outcomes

**Fallback Behavior:**
- If log file cannot be created or written, logging continues to console only
- File system errors are suppressed to avoid disrupting the application

### Error Handling
- Registry access errors are handled gracefully
- Missing registry paths are skipped automatically
- Uninstall failures provide detailed error information
- GUI errors display user-friendly message boxes

## Security Considerations

 **Important Security Notes**:
- The uninstall feature executes commands directly from the Windows registry
- Some applications may require elevated privileges for uninstallation
- Always verify the uninstall string before proceeding with uninstallation
- Be cautious when uninstalling system-critical applications

## Troubleshooting

### Common Issues
1. **"Access Denied" errors**: Run PowerShell as Administrator
2. **Execution Policy errors**: Use `-ExecutionPolicy Bypass` parameter
3. **No results found**: Try partial application names or check if the application is properly installed
4. **Uninstall failures**: Some applications require specific parameters or elevated privileges
5. **Empty clipboard operations**: The app now validates content before copying and displays a message if empty

### Logging
All operations are logged to both console and persistent log files in the `.\logs\` directory:
- **View Logs**: Navigate to the `logs` folder in the script directory
- **Log Format**: Daily files named `AppFinder-YYYY-MM-DD.log`
- **Retention**: Logs older than 30 days are automatically deleted
- **Troubleshooting**: Check log files for detailed error messages and operation history
- **Manual Cleanup**: You can safely delete old log files if needed

## Contributing

Contributions to improve AppFinder are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request with detailed description of changes
4. Ensure compatibility with PowerShell 5.1+

## License

This project is open-source and available under the [MIT License](LICENSE.md).

## Changelog

### Current Version (Kevin Kaminski Fork)
- **Modern UI**: Migrated to MenuStrip API for better compatibility
- **Progress Bar**: Visual feedback during registry searches
- **Enhanced Menu System**: Copy, Open in Notepad, Clear, and Help menus
- **Dual Access**: Features available via both menu bar and buttons
- **Input Validation**: Null-safe clipboard operations prevent exceptions
- **Copy to Clipboard**: Available in both menu and button with validation
- **Notepad Integration**: Export results to temporary file for external viewing
- **Clear Function**: Quick reset of output display
- **Comprehensive Error Handling**: Try-catch blocks with user-friendly messages
- **Uninstall Functionality**: GridView selection for multiple uninstall options
- **Console Mode Support**: Interactive CLI with GUI fallback
- **Multi-Registry Scanning**: 64-bit, 32-bit, and user-specific registry paths
- **Enhanced File-Based Logging**: Persistent logs with daily rotation, 30-day retention, and multi-level logging (INFO, WARNING, ERROR)
- **Audit Trail**: Complete logging of all user actions, searches, and uninstall operations for troubleshooting and compliance
