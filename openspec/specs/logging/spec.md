# logging Specification

## Purpose
TBD - created by archiving change add-enhanced-logging. Update Purpose after archive.
## Requirements
### Requirement: Persistent File-Based Logging
The system SHALL write all log entries to both console output AND a persistent log file stored in the `.\logs\` directory relative to the script location.

#### Scenario: Log file creation on first run
- **GIVEN** no logs directory exists
- **WHEN** the script starts
- **THEN** a `logs` directory SHALL be created
- **AND** a log file with format `AppFinder-YYYY-MM-DD.log` SHALL be created for the current date

#### Scenario: Append to existing log file
- **GIVEN** a log file exists for the current date
- **WHEN** the script runs
- **THEN** new log entries SHALL be appended to the existing file
- **AND** existing log entries SHALL remain unchanged

#### Scenario: Log file write failure
- **GIVEN** the logs directory is read-only or inaccessible
- **WHEN** the script attempts to write a log entry
- **THEN** the error SHALL be caught and suppressed
- **AND** logging SHALL continue to console only
- **AND** a warning SHALL be written to console indicating file logging is disabled

### Requirement: Log Entry Format
Each log entry SHALL follow the format: `[YYYY-MM-DD HH:MM:SS] [LEVEL] Message`

Where:
- Timestamp in ISO-8601 format with seconds precision
- Log level is one of: INFO, WARNING, ERROR
- Message is the descriptive text of the event

#### Scenario: INFO level log entry
- **WHEN** a normal operation occurs
- **THEN** the log entry SHALL use level "INFO"
- **AND** the format SHALL be `[2025-10-16 14:35:22] [INFO] Script started`

#### Scenario: ERROR level log entry
- **WHEN** an error occurs
- **THEN** the log entry SHALL use level "ERROR"
- **AND** the format SHALL be `[2025-10-16 14:35:22] [ERROR] Failed to execute uninstall`

### Requirement: Enhanced Write-Log Function
The `Write-Log` function SHALL be updated to accept an optional log level parameter and write to both console and file.

#### Scenario: Write-Log with default level
- **GIVEN** Write-Log is called without specifying level
- **WHEN** `Write-Log "Script started"`
- **THEN** log level SHALL default to "INFO"
- **AND** entry SHALL be written to both console and file

#### Scenario: Write-Log with explicit level
- **GIVEN** Write-Log is called with a log level
- **WHEN** `Write-Log "Error occurred" "ERROR"`
- **THEN** log level SHALL be "ERROR"
- **AND** entry SHALL be written to both console and file with ERROR level

### Requirement: Application Lifecycle Logging
The system SHALL log all application lifecycle events including startup, shutdown, and mode detection.

#### Scenario: Application startup logging
- **WHEN** the script starts
- **THEN** an INFO log SHALL be written: "Script started"
- **AND** an INFO log SHALL be written: "PowerShell version: [version]"

#### Scenario: GUI mode detection
- **WHEN** GUI mode is detected
- **THEN** an INFO log SHALL be written: "GUI mode detected"

#### Scenario: Console mode detection
- **WHEN** console mode is detected
- **THEN** an INFO log SHALL be written: "Console mode detected"

#### Scenario: Application shutdown
- **WHEN** the script ends (via finally block)
- **THEN** an INFO log SHALL be written: "Script ended"

### Requirement: User Action Logging
The system SHALL log all user interactions including searches, clipboard operations, file operations, and uninstalls.

#### Scenario: Search operation logging
- **WHEN** user initiates a search
- **THEN** an INFO log SHALL be written: "Search initiated: term='[search_term]'"
- **AND** when search completes, an INFO log SHALL be written: "Search completed: [count] results found"

#### Scenario: Copy to clipboard logging
- **WHEN** user clicks Copy button or menu
- **THEN** an INFO log SHALL be written: "Copy to clipboard executed"

#### Scenario: Open in Notepad logging
- **WHEN** user clicks Notepad button or menu
- **THEN** an INFO log SHALL be written: "Open in Notepad executed: [temp_file_path]"

#### Scenario: Clear output logging
- **WHEN** user clicks Clear menu
- **THEN** an INFO log SHALL be written: "Output cleared"

#### Scenario: Uninstall operation logging
- **WHEN** user initiates uninstall
- **THEN** a WARNING log SHALL be written: "Uninstall operation started: [application_name]"
- **AND** when uninstall completes, an INFO log SHALL be written: "Uninstall completed: [application_name]"

#### Scenario: Uninstall error logging
- **WHEN** uninstall operation fails
- **THEN** an ERROR log SHALL be written: "Uninstall failed: [application_name] - [error_message]"

### Requirement: Error Logging
The system SHALL log all errors caught in try-catch blocks with ERROR level.

#### Scenario: Exception logging
- **WHEN** an exception is caught in the global try-catch
- **THEN** an ERROR log SHALL be written: "Error occurred: [exception_message]"

#### Scenario: Registry access error
- **WHEN** a registry path cannot be accessed
- **THEN** a WARNING log SHALL be written: "Registry path inaccessible: [path]"

### Requirement: Log Rotation
The system SHALL create a new log file each day using the naming convention `AppFinder-YYYY-MM-DD.log`.

#### Scenario: Daily log rotation
- **GIVEN** the script ran yesterday
- **WHEN** the script runs today
- **THEN** a new log file SHALL be created for today's date
- **AND** yesterday's log file SHALL remain unchanged

#### Scenario: Multiple runs same day
- **GIVEN** the script runs multiple times in one day
- **WHEN** each run occurs
- **THEN** all runs SHALL append to the same date-stamped log file

### Requirement: Log Retention and Cleanup
The system SHALL automatically delete log files older than 30 days on script startup.

#### Scenario: Cleanup old logs
- **GIVEN** log files older than 30 days exist
- **WHEN** the script starts
- **THEN** log files older than 30 days SHALL be deleted
- **AND** an INFO log SHALL be written: "Cleaned up [count] old log files"

#### Scenario: No old logs to clean
- **GIVEN** no log files older than 30 days exist
- **WHEN** the script starts
- **THEN** no deletion SHALL occur
- **AND** cleanup runs silently without logging

#### Scenario: Cleanup failure
- **GIVEN** old log files exist but cannot be deleted
- **WHEN** cleanup attempts to delete them
- **THEN** the error SHALL be caught and suppressed
- **AND** a WARNING log SHALL be written: "Failed to clean up old log files: [error_message]"
- **AND** the application SHALL continue to run normally

### Requirement: Progress Bar Event Logging
The system SHALL log progress bar state changes during search operations.

#### Scenario: Progress bar visibility
- **WHEN** progress bar becomes visible
- **THEN** an INFO log SHALL be written: "Search progress started"
- **AND** when hidden, an INFO log SHALL be written: "Search progress completed"

