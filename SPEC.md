# PortMonitor - Mac 메뉴바 포트 모니터링 앱

## 아키텍처

**Tech Stack:** Swift + AppKit (macOS menu bar app)

**프로젝트 구조:**
```
PortMonitor/
├── Package.swift
├── Sources/
│   ├── main.swift
│   ├── Models/
│   │   └── PortInfo.swift
│   ├── Services/
│   │   ├── PortScanner.swift
│   │   └── ProcessKiller.swift
│   └── UI/
│       └── MenuBarController.swift
```

## 데이터 모델

**PortInfo:**
```swift
struct PortInfo {
    let port: Int
    let pid: Int
    let processName: String
    let protocol: String
    let state: String
}
```

## 서비스 계층

### PortScanner
- `scanPorts() -> [PortInfo]`: lsof 명령 실행하여 LISTEN 상태 포트 스캔
- TCP 포트 대상, 포트 번호 오름차순 정렬

### ProcessKiller
- `killProcess(pid: Int) -> Bool`: kill -9로 프로세스 강제 종료
- `killWithConfirmation(...)`: NSAlert로 확인 후 종료

## UI 요구사항

### 메뉴바
- 아이콘: network symbol
- 클릭 시 드롭다운 메뉴 표시

### 메뉴 구성
1. 헤더: "📊 포트 모니터 (N개)"
2. 포트 목록: ":PORT - PROCESS (PID: XXX) [PROTOCOL]"
3. 구분선
4. "🔄 새로고침" (단축키: ⌘R)
5. "종료" (단축키: ⌘Q)

### 동작
- 포트 항목 클릭 → 확인 다이얼로그 → 프로세스 종료
- 5초마다 자동 갱신
- 앱은 Dock에 표시 안 함 (.accessory 모드)

## 빌드 & 실행
```bash
swift build
swift run
```

## 역할 분담
- **Instance A**: Services 레이어 구현 (PortScanner, ProcessKiller)
- **Instance B**: UI 레이어 구현 (MenuBarController, main.swift, Package.swift)
