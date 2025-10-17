# Enhanced Logging Design

## Context
AppFinder currently uses `Write-Log` function that only outputs to console via `Write-Host`. When running in GUI mode, this output is not visible unless PowerShell console is open. Users and administrators need persistent logs for auditing user actions, troubleshooting issues, and maintaining compliance records.

**Constraints:**
- Must work in both GUI and console modes
- Must not impact application performance
- Must handle file system errors gracefully
- Should not fill disk space indefinitely

**Stakeholders:**
- End users: Need troubleshooting capability
- System administrators: Need audit trails
- Support teams: Need diagnostic information

## Goals / Non-Goals

### Goals
- Provide persistent file-based logging alongside console output
- Log all user interactions (searches, copies, uninstalls)
- Implement automatic log rotation to manage disk space
- Support configurable log levels (INFO, WARNING, ERROR)
- Maintain backward compatibility with existing console logging
- Gracefully handle file system errors

### Non-Goals
- Real-time log streaming or monitoring UI
- Remote logging to external systems
- Log encryption (may add later if compliance requires)
- Structured logging formats (JSON/XML) - plain text is sufficient
- Performance profiling or metrics collection

## Decisions

### Decision 1: Log File Location
**Choice:** Store logs in `.\logs\` subdirectory relative to script location

**Rationale:**
- Easy to find alongside script
- No special permissions required
- Can be included in backups
- User can easily delete if needed

**Alternatives Considered:**
- `%APPDATA%`: More Windows-standard but harder to find
- `%TEMP%`: Would be automatically cleaned up (not desired for auditing)
- Script parameter: Too complex for typical users

### Decision 2: Log File Naming
**Choice:** `AppFinder-YYYY-MM-DD.log` (daily rotation)

**Rationale:**
- Clear, sortable naming
- Automatic daily rotation
- Easy to identify old logs for cleanup
- Prevents single massive log file

**Alternatives Considered:**
- Single rolling file: Can grow indefinitely
- Size-based rotation: More complex logic, harder to manage
- Session-based files: Too many files for frequent usage

### Decision 3: Log Format
**Choice:** Plain text with format: `[YYYY-MM-DD HH:MM:SS] [LEVEL] Message`

**Rationale:**
- Human-readable without tools
- Compatible with text editors
- Easy to parse with PowerShell if needed
- Consistent with current `Write-Log` format

**Example:**
```
[2025-10-16 14:35:22] [INFO] Script started
[2025-10-16 14:35:23] [INFO] GUI mode detected
[2025-10-16 14:35:45] [INFO] Search initiated: term='chrome'
[2025-10-16 14:35:46] [INFO] Search completed: 3 results found
[2025-10-16 14:36:12] [INFO] Copy to clipboard executed
[2025-10-16 14:37:05] [WARNING] Uninstall operation started: Chrome Browser
[2025-10-16 14:37:15] [INFO] Uninstall completed successfully
[2025-10-16 14:40:30] [ERROR] Failed to write to log file: Access denied
```

### Decision 4: Enhanced Write-Log Function
**Choice:** Modify existing `Write-Log` to accept log level parameter and write to file

**Signature:**
```powershell
function Write-Log {
    param(
        [string]$message,
        [string]$level = "INFO"  # INFO, WARNING, ERROR
    )
}
```

**Rationale:**
- Backward compatible (level defaults to INFO)
- Single function handles both console and file
- Centralized error handling for file writes
- Minimal changes to existing code

### Decision 5: Log Retention
**Choice:** Keep logs for 30 days, implement cleanup on script startup

**Rationale:**
- Balances audit needs with disk space
- Automatic cleanup requires no user intervention
- 30 days sufficient for troubleshooting recent issues
- Can be adjusted via configuration variable

**Implementation:**
- On script startup, delete log files older than 30 days
- Silent failure if cleanup fails (non-critical)
- Log cleanup action itself

## Risks / Trade-offs

### Risk: File Write Failures
**Impact:** Logs may be incomplete if file system errors occur

**Mitigation:**
- Wrap file writes in try-catch
- Fall back to console-only logging if file unavailable
- Log the error condition itself to console
- Don't crash application if logging fails

### Risk: Sensitive Information in Logs
**Impact:** Log files may contain application names users search for

**Mitigation:**
- Document that logs contain search terms
- Recommend appropriate file permissions
- Consider adding future option to disable logging
- No passwords or sensitive registry data logged

### Risk: Disk Space Consumption
**Impact:** Logs could consume significant disk space over time

**Mitigation:**
- Daily rotation limits individual file size
- 30-day retention policy with automatic cleanup
- Logs stored in discoverable location for manual management
- Document log location in README

### Trade-off: Synchronous vs Asynchronous Writes
**Decision:** Use synchronous writes for simplicity

**Trade-off:**
- **Pro:** Guaranteed order, simpler code, no race conditions
- **Con:** Minor performance impact (negligible for user interactions)
- **Justification:** User actions are infrequent enough that sync writes are acceptable

## Migration Plan

### Implementation Steps
1. **Phase 1:** Update `Write-Log` function with file writing capability
2. **Phase 2:** Add log level parameter to all existing `Write-Log` calls
3. **Phase 3:** Add logging to GUI event handlers
4. **Phase 4:** Implement log rotation and cleanup
5. **Phase 5:** Update documentation

### Rollback Strategy
If logging causes issues:
- Remove file writing code from `Write-Log`
- Revert to console-only logging
- No data loss - logging is observational only

### User Communication
- Update README.md with logging section
- Document log location and format
- Explain retention policy
- Note that logs can be safely deleted

## Open Questions

1. **Q:** Should we add a GUI menu option to open the logs folder?
   **A:** Future enhancement - not in scope for initial implementation

2. **Q:** Should log level be user-configurable via parameter?
   **A:** Future enhancement - default to INFO for all events initially

3. **Q:** Should we log the full registry paths scanned or just count?
   **A:** Log count only to avoid verbosity - full paths available via --debug parameter (future)

4. **Q:** Should uninstall logs include the uninstall string executed?
   **A:** Yes - valuable for troubleshooting, but sanitize if it contains paths with usernames
