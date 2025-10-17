# Enhanced Logging Feature

## Why
The current logging mechanism (`Write-Log`) only outputs to the console, which is not visible when the application runs in GUI mode. For auditing, troubleshooting, and compliance purposes, we need persistent log files that capture all user actions and system events, regardless of whether the application is running in GUI or console mode.

## What Changes
- Add persistent file-based logging to supplement console logging
- Log all GUI interactions (button clicks, menu selections, searches)
- Log application lifecycle events (startup, shutdown, errors)
- Log uninstall operations with application names and outcomes
- Add log rotation to prevent disk space issues
- Include configurable log levels (INFO, WARNING, ERROR)
- Add timestamp, log level, and event context to each log entry
- Create logs directory if it doesn't exist
- **BREAKING**: None (additive change only)

## Impact
- **Affected specs**: New capability - `logging` spec
- **Affected code**: 
  - `AppFinder.ps1` - Enhanced `Write-Log` function
  - `AppFinder.ps1` - Add logging calls to all GUI event handlers
  - `AppFinder.ps1` - Add log file path configuration
  - `AppFinder.ps1` - Add log rotation logic
- **User Experience**: Minimal impact - logs created in background
- **Performance**: Negligible - asynchronous file writes
- **Security**: Log files may contain application names users search for
