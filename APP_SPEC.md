# Port Manager - Mac Menu Bar App

## Tech Stack
**Swift + SwiftUI** (Native macOS menu bar app)

## Core Features

### 1. Port Scanning
- Scan common ports (3000-9999, 80, 443, 5432, 27017, 6379, 8080, 8000)
- Show process name, PID, port number
- Real-time refresh (manual + auto every 5s)

### 2. Process Management
- Kill process by PID
- Confirmation dialog before kill
- Success/error notifications

### 3. UI Components
- Menu bar icon (network symbol)
- Dropdown menu with:
  - Port list (scrollable)
  - Refresh button
  - Quit option
- Each port entry shows: `PORT | PID | Process Name [Kill]`

## Implementation Structure

```
PortManager/
├── PortManagerApp.swift       # App entry point + menu bar setup
├── Models/
│   └── PortInfo.swift          # Data model for port info
├── Services/
│   ├── PortScanner.swift       # Execute lsof/netstat commands
│   └── ProcessKiller.swift     # Kill process functionality
└── Views/
    └── MenuBarView.swift       # SwiftUI menu content
```

## System Commands

**Port scanning:**
```bash
lsof -iTCP -sTCP:LISTEN -n -P
```

**Process kill:**
```bash
kill -9 <PID>
```

## Data Model

```swift
struct PortInfo: Identifiable {
    let id = UUID()
    let port: Int
    let pid: Int
    let processName: String
}
```

## Next Steps
1. Initialize Swift project with Xcode
2. Implement PortScanner service
3. Implement ProcessKiller service
4. Build menu bar UI
5. Add refresh & kill actions
