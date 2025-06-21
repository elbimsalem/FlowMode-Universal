# FlowMode Granular Implementation Plan

Based on my analysis and the priority_fixes.md document, here's a detailed step-by-step plan. Fixes 1 and 2 are already completed, so we'll start with the remaining priority fixes and additional critical issues.

## Phase 1: Settings Persistence Debouncing (Priority Fix 3)

### Step 1.1: Add Combine import to TimerService
**File**: `FlowMode/Core/Services/TimerService.swift`
**Action**: Add `import Combine` at the top if not already present
**Test**: Build should succeed

### Step 1.2: Add debounce to settings observer
**File**: `FlowMode/Core/Services/TimerService.swift`
**Find**: Lines 25-31 in init()
```swift
self.$settings
    .dropFirst()
    .sink { [weak self] _ in
        self?.saveSettings()
    }
    .store(in: &cancellables)
```
**Replace with**:
```swift
self.$settings
    .dropFirst()
    .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
    .sink { [weak self] _ in
        self?.saveSettings()
    }
    .store(in: &cancellables)
```
**Test**: Rapidly change timer settings, verify only one save occurs after 500ms delay

### Step 1.3: Add error handling to saveSettings
**File**: `FlowMode/Core/Services/TimerService.swift`
**Find**: `saveSettings()` method
**Replace with**:
```swift
private func saveSettings() {
    do {
        let data = try JSONEncoder().encode(settings)
        UserDefaults.standard.set(data, forKey: "TimerSettings")
    } catch {
        print("⚠️ Failed to save settings: \(error)")
    }
}
```
**Test**: Settings should still save correctly

### Step 1.4: Add error handling to loadSettings
**File**: `FlowMode/Core/Services/TimerService.swift`
**Find**: `loadSettings()` method
**Replace with**:
```swift
private static func loadSettings() -> TimerSettings {
    guard let data = UserDefaults.standard.data(forKey: "TimerSettings") else {
        return TimerSettings()
    }
    
    do {
        return try JSONDecoder().decode(TimerSettings.self, from: data)
    } catch {
        print("⚠️ Failed to load settings, using defaults: \(error)")
        return TimerSettings()
    }
}
```
**Test**: App should start with default settings if UserDefaults is corrupted

## Phase 2: Memory Leak Fixes

### Step 2.1: Add deinit to BackgroundTaskService
**File**: `FlowMode/Core/Services/BackgroundTaskService.swift`
**Action**: Add after the `setupNotificationObservers()` method:
```swift
deinit {
    cancellables.removeAll()
    endBackgroundTask()
}
```
**Test**: Use Instruments to verify BackgroundTaskService is properly deallocated

### Step 2.2: Fix weak self capture in TimerService
**File**: `FlowMode/Core/Services/TimerService.swift`
**Find**: Timer.scheduledTimer calls (multiple locations)
**Replace each with weak self capture**:
```swift
timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
    self?.updateElapsedTime()
}
```
**Test**: Timer should still function correctly, verify no retain cycles in Instruments

## Phase 3: Thread Safety Fixes

### Step 3.1: Remove @MainActor from SubscriptionService class
**File**: `FlowMode/Core/Services/SubscriptionService.swift`
**Find**: Line with `@MainActor class SubscriptionService`
**Replace with**: `class SubscriptionService: ObservableObject`
**Test**: Build should succeed

### Step 3.2: Add @MainActor to UI-updating methods
**File**: `FlowMode/Core/Services/SubscriptionService.swift`
**Find**: Methods that update @Published properties
**Add** `@MainActor` to each method that updates UI:
```swift
@MainActor
private func updateUIState() {
    // existing code
}
```
**Test**: UI updates should still work correctly

### Step 3.3: Fix async MainActor calls
**File**: `FlowMode/Core/Services/SubscriptionService.swift`
**Find**: `await MainActor.run` blocks
**Ensure** they only wrap UI updates, not business logic
**Test**: Subscription flow should work without deadlocks

## Phase 4: Gesture Conflict Resolution

### Step 4.1: Create custom gesture modifier
**File**: Create new file `FlowMode/Views/Timer/TimerGestureModifier.swift`
**Add**:
```swift
import SwiftUI

struct TimerGestureModifier: ViewModifier {
    let onTap: () -> Void
    let onDoubleTap: () -> Void
    let onLongPress: () -> Void
    
    @State private var tapCount = 0
    @State private var tapTimer: Timer?
    
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                handleTap()
            }
            .onLongPressGesture(minimumDuration: 1.0) {
                tapTimer?.invalidate()
                tapCount = 0
                onLongPress()
            }
    }
    
    private func handleTap() {
        tapCount += 1
        
        if tapCount == 1 {
            tapTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                if tapCount == 1 {
                    onTap()
                }
                tapCount = 0
            }
        } else if tapCount == 2 {
            tapTimer?.invalidate()
            onDoubleTap()
            tapCount = 0
        }
    }
}
```
**Test**: File should compile

### Step 4.2: Replace gesture handlers in TimerView
**File**: `FlowMode/Views/Timer/TimerView.swift`
**Find**: Lines with `.onTapGesture(count: 2)`, `.onTapGesture`, `.onLongPressGesture`
**Replace with**:
```swift
.modifier(TimerGestureModifier(
    onTap: handleTimerTap,
    onDoubleTap: handleTimerDoubleTap,
    onLongPress: handleTimerLongPress
))
```
**Test**: All gestures should work without conflicts

## Phase 5: Background State Improvements (Priority Fix 4)

### Step 5.1: Add background interruption state
**File**: `FlowMode/Core/Services/TimerService.swift`
**Add** to properties:
```swift
@Published var wasInterruptedByBackground: Bool = false
```
**Test**: Build should succeed

### Step 5.2: Add background time adjustment method
**File**: `FlowMode/Core/Services/TimerService.swift`
**Add** new method:
```swift
func adjustForBackgroundTime(_ duration: TimeInterval) {
    guard let startTime = startTime else { return }
    self.startTime = startTime.addingTimeInterval(-duration)
}
```
**Test**: Method should compile

### Step 5.3: Update background handling logic
**File**: `FlowMode/Core/Services/BackgroundTaskService.swift`
**Find**: `updateTimerFromBackground()` method
**Replace** the switch case for `.breaking`:
```swift
case .breaking:
    let remainingTime = timerService.remainingPauseSeconds
    if backgroundDuration >= Double(remainingTime) {
        timerService.wasInterruptedByBackground = true
        timerService.pauseBreakTimer()
    } else {
        timerService.adjustForBackgroundTime(backgroundDuration)
    }
```
**Test**: Background handling should pause instead of reset

### Step 5.4: Add interruption alert to TimerView
**File**: `FlowMode/Views/Timer/TimerView.swift`
**Add** after the `.sheet` modifier:
```swift
.alert("Timer Interrupted", isPresented: $timerService.wasInterruptedByBackground) {
    Button("Continue") {
        timerService.resumeBreakTimer()
        timerService.wasInterruptedByBackground = false
    }
    Button("Reset") {
        timerService.resetTimer()
        timerService.wasInterruptedByBackground = false
    }
} message: {
    Text("Your timer was paused due to extended background time.")
}
```
**Test**: Alert should appear when returning from extended background

## Phase 6: Structured Logging (Priority Fix 5)

### Step 6.1: Create Logger utility
**File**: Create new file `FlowMode/Core/Utilities/Logger.swift`
**Add**:
```swift
import os.log

enum LogLevel {
    case debug, info, warning, error
}

struct Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "FlowMode"
    
    static let timer = Logger(category: "Timer")
    static let subscription = Logger(category: "Subscription")
    static let sound = Logger(category: "Sound")
    static let notification = Logger(category: "Notification")
    static let background = Logger(category: "Background")
    
    private let osLog: OSLog
    
    private init(category: String) {
        self.osLog = OSLog(subsystem: Logger.subsystem, category: category)
    }
    
    func log(_ level: LogLevel, _ message: String) {
        let type: OSLogType
        switch level {
        case .debug: type = .debug
        case .info: type = .info
        case .warning: type = .default
        case .error: type = .error
        }
        os_log("%{public}@", log: osLog, type: type, message)
    }
}
```
**Test**: File should compile

### Step 6.2: Replace prints in TimerService
**File**: `FlowMode/Core/Services/TimerService.swift`
**Find**: All `print` statements
**Replace** each with appropriate Logger call:
- `print("⚠️ Failed to save settings: \(error)")` → `Logger.timer.log(.error, "Failed to save settings: \(error)")`
- `print("⚠️ Failed to load settings, using defaults: \(error)")` → `Logger.timer.log(.warning, "Failed to load settings: \(error)")`
**Test**: Console.app should show structured logs

### Step 6.3: Add key operation logging to TimerService
**File**: `FlowMode/Core/Services/TimerService.swift`
**Add** at the start of each major method:
```swift
func startWorkTimer() {
    Logger.timer.log(.info, "Starting work timer")
    // existing code
}

func pauseWorkTimer() {
    Logger.timer.log(.info, "Pausing work timer")
    // existing code
}
```
**Test**: Timer operations should log to Console.app

### Step 6.4: Replace prints in SoundService
**File**: `FlowMode/Core/Services/SoundService.swift`
**Find**: All `print` statements
**Replace** with Logger calls
**Test**: Sound operations should log to Console.app

### Step 6.5: Replace prints in remaining services
**Files**: `NotificationService.swift`, `SubscriptionService.swift`, `BackgroundTaskService.swift`
**Action**: Replace all print statements with appropriate Logger calls
**Test**: All services should use structured logging

## Phase 7: Additional Critical Fixes

### Step 7.1: Add missing accessibility labels
**File**: `FlowMode/Views/Timer/TimerDisplayView.swift`
**Add** after the view body:
```swift
.accessibilityLabel("Timer showing \(TimeFormatter.formatSeconds(seconds))")
.accessibilityHint(timerState == .idle ? "Double tap to start timer" : "Double tap to reset")
.accessibilityAddTraits(.updatesFrequently)
```
**Test**: VoiceOver should read timer correctly

### Step 7.2: Fix potential division by zero
**File**: `FlowMode/Core/Services/TimerService.swift`
**Find**: `progressPercentage` computed property
**Add** safety check:
```swift
let maxSeconds = max(1, settings.maxWorkTimeMinutes * 60)
```
**Test**: Progress should never cause division by zero

### Step 7.3: Add error recovery UI component
**File**: Create new file `FlowMode/Views/Common/ErrorView.swift`
**Add**:
```swift
import SwiftUI

struct ErrorView: View {
    let title: String
    let message: String
    let retry: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let retry = retry {
                Button("Try Again", action: retry)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}
```
**Test**: Preview should show error view correctly

## Testing Checkpoints

After each phase:
1. **Build Test**: App compiles without warnings
2. **Functional Test**: Core timer functionality works
3. **Memory Test**: Check for leaks with Instruments
4. **Performance Test**: Verify no UI lag
5. **Regression Test**: All existing features still work

## Success Metrics

- [ ] All print statements replaced with structured logging
- [ ] No memory leaks detected in Instruments
- [ ] Settings save at most once per 500ms
- [ ] Background interruptions handled gracefully
- [ ] No gesture conflicts
- [ ] Thread-safe operations
- [ ] Improved error handling throughout