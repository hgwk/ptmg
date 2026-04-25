# ptmg

macOS menu bar app for port monitoring.

## Features

- **Menu bar port monitoring** — Flat list UI showing all listening ports
- **One-click process kill** — With PID reuse detection and safety confirmation
- **Dynamic icon states** — Changes appearance in low-power mode
- **Launch at login** — SMAppService integration
- **Popover search** — Real-time filtering of ports
- **CLI** — List (`-l`), watch (`-w`), kill (`-k`) commands

## Security Hardening

- Port validation (1-65535)
- PID validation (1-999999)
- Process name verification before kill
- 10s timeout on all subprocess calls
- Explicit FileHandle closing
- NSLock thread-safety for UserDefaults

## Install

```bash
# Build from source
swift build -c release

# Or copy prebuilt binary
cp ptmg /usr/local/bin/
```

## Usage

### GUI
Double-click `ptmg` to run as menu bar app.

### CLI
```bash
ptmg --list          # List all listening ports
ptmg --watch 3000    # Watch port 3000 for changes
ptmg --kill 3000     # Kill process on port 3000
```

## Build

```bash
swift build              # Debug
swift build -c release   # Release
swift test               # Run tests (requires Xcode)
```

## Requirements

- macOS 13+
- Swift 5.9+

## License

MIT
