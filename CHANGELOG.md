# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.0.0] - 2026-04-25

### Added

- Menu bar port monitoring with flat list UI
- One-click process kill with confirmation dialog
- PID reuse detection via `kill -0` + process name verification
- Dynamic menu bar icon states (normal / low-power mode)
- Launch at login support via `SMAppService`
- Popover search with real-time port filtering
- `pm` CLI companion with `-l`, `-w`, `-k` flags
- Port validation (1-65535) and PID validation (1-999999)
- 10-second timeout on all subprocess execution
- Explicit FileHandle resource cleanup
- Thread-safe `FavoriteService` with `NSLock`
- Unit tests for core models and services
- Integration test for CLI commands

### Security

- Validate port numbers before parsing
- Validate PID range before kill operations
- Verify process name matches before killing to prevent PID reuse attacks
- Timeout all `lsof`/`ps`/`kill` calls to prevent indefinite hangs

[1.0.0]: https://github.com/hgwk/PortManager/releases/tag/v1.0.0
