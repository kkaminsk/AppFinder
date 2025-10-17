# Project Context

## Purpose
AppFinder is a PowerShell-based Windows application finder and manager that allows users to easily search for installed applications and retrieve detailed information such as Uninstall String, Version, Publisher, and Install Location without manually searching through the Windows registry.

**Goals:**
- Provide a user-friendly GUI alternative to manual registry searches
- Enable quick application discovery and uninstallation
- Support both GUI and console modes for different workflows
- Offer real-time visual feedback during registry scanning operations
- Maintain compatibility with PowerShell 5.1+ and Windows systems

## Tech Stack
- **PowerShell 5.1+** - Core scripting language
- **.NET Windows Forms** - GUI framework (System.Windows.Forms)
  - MenuStrip API for modern menu bars
  - ToolStripMenuItem for menu items
  - Standard WinForms controls (Button, TextBox, Label, ProgressBar)
- **Windows Registry** - Data source for application information
- **Native Windows APIs** - Process management and clipboard operations

## Project Conventions

### Code Style
- **Naming Conventions:**
  - Variables: camelCase with descriptive prefixes (`$txtOutput`, `$btnSearch`, `$menuHelp`)
  - Functions: PascalCase with verb-noun pattern (`Search`, `Uninstall`, `Show-Error`, `Write-Log`)
  - Script-scoped variables: `$script:` prefix for shared state (`$script:uninstallInfo`)
- **Formatting:**
  - Comments with `#` for sections and inline explanations
  - Consistent indentation (4 spaces or tabs)
  - Clear separation between control creation and event handler assignment
- **UI Controls:**
  - All controls explicitly positioned with `System.Drawing.Point`
  - Width/Height explicitly defined for consistency
  - Descriptive Text properties for user-facing elements

### Architecture Patterns
- **Event-Driven Architecture:** GUI controls use event handlers (`.Add_Click`, `.Add_KeyDown`)
- **Functional Separation:**
  - Utility functions: `Show-Error`, `Write-Log`
  - Core business logic: `Search`, `Uninstall`
  - UI setup code at script level
- **Error Handling Pattern:**
  - Global try-catch-finally block wraps entire script
  - Individual error handling within functions
  - User-friendly MessageBox displays for errors
  - Console logging for debugging
- **State Management:**
  - Script-scoped variables for shared state
  - Controls referenced directly by variable name in event handlers
- **Progress Feedback:**
  - Progress bar visible during operations, hidden when complete
  - Form.Refresh() calls ensure real-time UI updates

### Testing Strategy
- **Manual Testing Focus:**
  - Test with various application names (partial matches, exact matches)
  - Verify uninstall functionality with different application types
  - Test error conditions (empty searches, missing registry paths)
  - Validate clipboard operations with empty and populated results
- **Compatibility Testing:**
  - PowerShell 5.1 minimum requirement
  - Test on Windows 10/11 systems
  - Verify both 64-bit and 32-bit application detection
- **Edge Cases:**
  - Applications with no uninstall string
  - Multiple applications with similar names
  - Registry paths that don't exist
  - Empty search results

### Git Workflow
- **Main Branch:** Stable production-ready code
- **Feature Branches:** Use descriptive names (e.g., `patch-1` for UI improvements)
- **Commit Messages:** Descriptive, documenting changes made
- **Merge Strategy:** Resolve conflicts carefully, test before merging
- **Fork Origin:** This is a fork from Marin Alexandruradu's original project by Kevin Kaminski

## Domain Context

### Windows Registry Structure
- **HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall** - 64-bit applications
- **HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall** - 32-bit apps on 64-bit systems
- **HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall** - User-specific installations

### Application Information Properties
- **DisplayName:** Application's display name (used for searching)
- **UninstallString:** Command to uninstall (may include parameters)
- **DisplayVersion:** Version number
- **Publisher:** Software developer/publisher
- **InstallLocation:** Installation directory path

### Uninstall Behavior
- Some applications require elevated privileges
- Uninstall strings may execute silently or show UI
- System-critical applications should not be uninstalled
- cmd.exe wrapper used to execute uninstall strings

## Important Constraints

### Security Constraints
- **Execution Policy:** Scripts must be run with `-ExecutionPolicy Bypass` or signed
- **Administrator Privileges:** May be required for some uninstall operations
- **Uninstall String Validation:** Direct execution of registry values poses security risk
- **User Confirmation:** Always validate before uninstalling

### Technical Constraints
- **PowerShell Version:** Minimum 5.1 required
- **Windows Only:** Platform-specific (uses Windows Registry and .NET Forms)
- **API Compatibility:** Must use MenuStrip API (not legacy MainMenu) for PowerShell compatibility
- **Clipboard Operations:** Require non-null/non-empty strings to prevent exceptions
- **UI Thread:** Form operations must occur on main UI thread

### User Experience Constraints
- **Responsiveness:** Form.Refresh() needed during long operations
- **Progress Feedback:** Progress bar should increment per registry path (not per key)
- **Error Messages:** Must be user-friendly, not technical exceptions
- **Dual Access:** Features accessible via both menu and buttons where practical

## External Dependencies
- **.NET Framework:** System.Windows.Forms assembly
- **Windows Registry:** Read access to HKLM and HKCU registry hives
- **Windows Shell:** notepad.exe for external viewing
- **cmd.exe:** For executing uninstall strings
- **Process Management:** Start-Process cmdlet for launching applications
- **Clipboard API:** System.Windows.Forms.Clipboard for copy operations
- **Temporary File System:** GetTempFileName() for Notepad integration
