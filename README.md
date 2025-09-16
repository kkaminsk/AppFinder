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
- **Menu system** with Help menu and About option linking to GitHub repository
- **Search input** with Enter key support for quick searches
- **Multi-line output display** with vertical scrolling
- **Copy to Clipboard** functionality for easy sharing of results
- **Open in Notepad** feature for external viewing and editing of results
- **One-click Uninstall** with intelligent selection for multiple uninstall options

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
   - **Copy**: Click to copy all search results to clipboard
   - **Notepad**: Click to open results in a new Notepad window
   - **Uninstall**: Click to uninstall the found application(s)

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
- Built using .NET Windows Forms for cross-compatibility
- Implements comprehensive error handling with try-catch blocks
- Uses PowerShell's registry access capabilities
- Supports both synchronous and asynchronous operations

### Logging System
The script includes detailed logging with timestamps:
- Script startup and shutdown events
- GUI creation and display events
- Search operations and results
- Error conditions and exceptions
- Console mode operations

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

### Logging
All operations are logged with timestamps. Monitor the console output for detailed information about script execution and any errors encountered.

## Contributing

Contributions to improve AppFinder are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request with detailed description of changes
4. Ensure compatibility with PowerShell 5.1+

## License

This project is open-source and available under the [MIT License](LICENSE).

## Changelog

### Current Version (Kevin Kaminski Fork)
- Enhanced GUI with menu system
- Added copy to clipboard functionality
- Implemented Notepad integration
- Added comprehensive error handling and logging
- Improved uninstall functionality with GridView selection
- Added console mode support
- Enhanced registry scanning across multiple hives
