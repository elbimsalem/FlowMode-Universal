# FlowMode Theme Feature Implementation Guide

## Overview
This guide provides granular steps to implement theming support for the timer display in FlowMode. This is a premium feature that allows subscribers to select different visual themes for the timer.

## Prerequisites
- Ensure all priority fixes from `priority_fixes.md` are completed
- Familiarity with the existing codebase structure
- Understanding of SwiftUI theming patterns

## Implementation Phases

## Phase 1: Theme Model Definition

### Step 1.1: Create Theme Model
**File**: Create new file `FlowMode/Core/Models/Theme.swift`
**Action**: Define the Theme struct
```swift
import SwiftUI

struct Theme: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let isPremium: Bool
    
    // Timer ring colors
    let primaryRingColor: CodableColor
    let secondaryRingColor: CodableColor
    let ringBackgroundColor: CodableColor
    
    // Timer text colors
    let primaryTextColor: CodableColor
    let secondaryTextColor: CodableColor
    
    // Background
    let backgroundColor: CodableColor
    let useGradientBackground: Bool
    let gradientEndColor: CodableColor?
    
    // Visual effects
    let glowEffect: Bool
    let glowColor: CodableColor?
    let glowRadius: Double
}
```
**Test**: File should compile without errors

### Step 1.2: Create CodableColor Helper
**File**: Create new file `FlowMode/Core/Models/CodableColor.swift`
**Action**: Create a Codable wrapper for Color
```swift
import SwiftUI

struct CodableColor: Codable, Equatable {
    let red: Double
    let green: Double
    let blue: Double
    let opacity: Double
    
    init(color: Color) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.opacity = Double(a)
    }
    
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}
```
**Test**: Should handle Color to CodableColor conversion

### Step 1.3: Add Theme Selection to TimerSettings
**File**: `FlowMode/Core/Models/TimerSettings.swift`
**Action**: Add theme property
**Find**: End of struct properties
**Add**:
```swift
var selectedThemeId: String = "default"
```
**Test**: Settings should still save/load correctly

## Phase 2: Default Themes Creation

### Step 2.1: Create ThemeProvider
**File**: Create new file `FlowMode/Core/Services/ThemeProvider.swift`
**Action**: Define default themes
```swift
import SwiftUI

struct ThemeProvider {
    static let defaultThemes: [Theme] = [
        Theme(
            id: "default",
            name: "Classic",
            isPremium: false,
            primaryRingColor: CodableColor(color: .blue),
            secondaryRingColor: CodableColor(color: .orange),
            ringBackgroundColor: CodableColor(color: Color(.systemGray5)),
            primaryTextColor: CodableColor(color: .primary),
            secondaryTextColor: CodableColor(color: .secondary),
            backgroundColor: CodableColor(color: Color(.systemBackground)),
            useGradientBackground: false,
            gradientEndColor: nil,
            glowEffect: false,
            glowColor: nil,
            glowRadius: 0
        ),
        Theme(
            id: "midnight",
            name: "Midnight",
            isPremium: true,
            primaryRingColor: CodableColor(color: Color(hex: "4A90E2")),
            secondaryRingColor: CodableColor(color: Color(hex: "7B68EE")),
            ringBackgroundColor: CodableColor(color: Color(hex: "1A1A2E")),
            primaryTextColor: CodableColor(color: .white),
            secondaryTextColor: CodableColor(color: Color(hex: "B8B8D0")),
            backgroundColor: CodableColor(color: Color(hex: "0F0F1E")),
            useGradientBackground: true,
            gradientEndColor: CodableColor(color: Color(hex: "1A1A2E")),
            glowEffect: true,
            glowColor: CodableColor(color: Color(hex: "4A90E2")),
            glowRadius: 10
        )
    ]
    
    static func theme(withId id: String) -> Theme {
        defaultThemes.first { $0.id == id } ?? defaultThemes[0]
    }
}
```
**Test**: Should provide at least two themes

### Step 2.2: Add Color Extension for Hex
**File**: Create new file `FlowMode/Core/Utilities/Color+Extensions.swift`
**Action**: Add hex initializer
```swift
import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```
**Test**: Color(hex: "FF0000") should create red color

## Phase 3: Theme Service Implementation

### Step 3.1: Create ThemeService
**File**: Create new file `FlowMode/Core/Services/ThemeService.swift`
**Action**: Create theme management service
```swift
import SwiftUI
import Combine

class ThemeService: ObservableObject {
    @Published var currentTheme: Theme
    @Published var availableThemes: [Theme] = ThemeProvider.defaultThemes
    
    private let timerService: TimerService
    private var cancellables = Set<AnyCancellable>()
    
    init(timerService: TimerService) {
        self.timerService = timerService
        self.currentTheme = ThemeProvider.theme(withId: timerService.settings.selectedThemeId)
        
        // Observe theme changes
        timerService.$settings
            .map { $0.selectedThemeId }
            .removeDuplicates()
            .sink { [weak self] themeId in
                self?.currentTheme = ThemeProvider.theme(withId: themeId)
            }
            .store(in: &cancellables)
    }
    
    func selectTheme(_ theme: Theme) {
        timerService.settings.selectedThemeId = theme.id
    }
    
    func canSelectTheme(_ theme: Theme, subscriptionStatus: SubscriptionStatus) -> Bool {
        return !theme.isPremium || subscriptionStatus.hasActiveAccess
    }
}
```
**Test**: Service should initialize with default theme

### Step 3.2: Add ThemeService to App
**File**: `FlowMode/FlowModeApp.swift`
**Action**: Initialize and inject ThemeService
**Find**: After `@StateObject private var timerService`
**Add**:
```swift
@StateObject private var themeService: ThemeService
```
**Find**: In `init()`
**Add**:
```swift
let timer = TimerService()
_timerService = StateObject(wrappedValue: timer)
_themeService = StateObject(wrappedValue: ThemeService(timerService: timer))
```
**Find**: In `.environmentObject(timerService)`
**Add after**:
```swift
.environmentObject(themeService)
```
**Test**: App should compile and run

## Phase 4: Update Timer Display Components

### Step 4.1: Update TimerProgressRing for Theming
**File**: `FlowMode/Views/Timer/TimerProgressRing.swift`
**Action**: Add theme support
**Find**: At the top of struct
**Add**:
```swift
@EnvironmentObject var themeService: ThemeService
```
**Find**: Color definitions in body
**Replace** hardcoded colors with theme colors:
```swift
// Replace .gray.opacity(0.2) with:
themeService.currentTheme.ringBackgroundColor.color

// Replace .blue with:
themeService.currentTheme.primaryRingColor.color

// Replace .orange with:
themeService.currentTheme.secondaryRingColor.color
```
**Test**: Timer ring should use theme colors

### Step 4.2: Update TimerDisplayView for Theming
**File**: `FlowMode/Views/Timer/TimerDisplayView.swift`
**Action**: Add theme support
**Find**: At the top of struct
**Add**:
```swift
@EnvironmentObject var themeService: ThemeService
```
**Find**: `.foregroundColor` modifiers
**Replace** with theme colors:
```swift
// Primary text color
.foregroundColor(themeService.currentTheme.primaryTextColor.color)

// Secondary text color
.foregroundColor(themeService.currentTheme.secondaryTextColor.color)
```
**Test**: Timer text should use theme colors

### Step 4.3: Add Glow Effect Support
**File**: `FlowMode/Views/Timer/TimerView.swift`
**Action**: Add glow effect to timer
**Find**: After the TimerProgressRing ZStack
**Add** conditional glow:
```swift
.if(themeService.currentTheme.glowEffect) { view in
    view.shadow(
        color: themeService.currentTheme.glowColor?.color ?? .clear,
        radius: themeService.currentTheme.glowRadius
    )
}
```
**Test**: Glow should appear for themes with glowEffect enabled

### Step 4.4: Create View Extension for Conditional Modifier
**File**: Create new file `FlowMode/Core/Utilities/View+Extensions.swift`
**Action**: Add conditional modifier extension
```swift
import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
```
**Test**: Conditional modifiers should work

### Step 4.5: Add Background Theming
**File**: `FlowMode/Views/Timer/TimerView.swift`
**Action**: Add themed background
**Find**: Main VStack
**Wrap** in ZStack with background:
```swift
ZStack {
    // Background
    if themeService.currentTheme.useGradientBackground,
       let gradientEnd = themeService.currentTheme.gradientEndColor {
        LinearGradient(
            colors: [
                themeService.currentTheme.backgroundColor.color,
                gradientEnd.color
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    } else {
        themeService.currentTheme.backgroundColor.color
            .ignoresSafeArea()
    }
    
    // Existing VStack content
    VStack(spacing: 40) {
        // ... existing content
    }
}
```
**Test**: Background should change with theme

## Phase 5: Settings UI Implementation

### Step 5.1: Create Theme Selection View
**File**: Create new file `FlowMode/Views/Settings/ThemeSelectionView.swift`
**Action**: Create theme picker UI
```swift
import SwiftUI

struct ThemeSelectionView: View {
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var subscriptionService: SubscriptionService
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(themeService.availableThemes) { theme in
                ThemeRow(
                    theme: theme,
                    isSelected: theme.id == themeService.currentTheme.id,
                    isLocked: !themeService.canSelectTheme(theme, subscriptionStatus: subscriptionService.subscriptionStatus)
                ) {
                    if themeService.canSelectTheme(theme, subscriptionStatus: subscriptionService.subscriptionStatus) {
                        themeService.selectTheme(theme)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Select Theme")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
```
**Test**: View should list all available themes

### Step 5.2: Create Theme Row Component
**File**: Create new file `FlowMode/Views/Settings/ThemeRow.swift`
**Action**: Create theme row UI
```swift
import SwiftUI

struct ThemeRow: View {
    let theme: Theme
    let isSelected: Bool
    let isLocked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                // Theme preview
                ThemePreview(theme: theme)
                    .frame(width: 60, height: 60)
                
                VStack(alignment: .leading) {
                    Text(theme.name)
                        .font(.headline)
                    
                    if theme.isPremium {
                        Label("Premium", systemImage: "crown.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                } else if isLocked {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLocked)
        .opacity(isLocked ? 0.6 : 1.0)
    }
}
```
**Test**: Row should show theme info and lock status

### Step 5.3: Create Theme Preview Component
**File**: Create new file `FlowMode/Views/Settings/ThemePreview.swift`
**Action**: Create mini timer preview
```swift
import SwiftUI

struct ThemePreview: View {
    let theme: Theme
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.backgroundColor.color)
            
            // Mini timer ring
            Circle()
                .stroke(theme.ringBackgroundColor.color, lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(theme.primaryRingColor.color, lineWidth: 4)
                .rotationEffect(.degrees(-90))
            
            Circle()
                .trim(from: 0, to: 0.3)
                .stroke(theme.secondaryRingColor.color, lineWidth: 4)
                .rotationEffect(.degrees(-90))
                .scaleEffect(1.1)
            
            // Timer text preview
            Text("25:00")
                .font(.caption2)
                .foregroundColor(theme.primaryTextColor.color)
        }
        .if(theme.glowEffect) { view in
            view.shadow(
                color: theme.glowColor?.color ?? .clear,
                radius: theme.glowRadius / 3
            )
        }
    }
}
```
**Test**: Should show miniature theme preview

### Step 5.4: Add Theme Settings to SettingsView
**File**: `FlowMode/Views/Settings/SettingsView.swift`
**Action**: Add theme selection option
**Find**: In the Timer Settings section (after existing settings)
**Add**:
```swift
if subscriptionService.subscriptionStatus.hasActiveAccess {
    NavigationLink(destination: ThemeSelectionView()) {
        HStack {
            Label("Theme", systemImage: "paintbrush.fill")
            Spacer()
            Text(themeService.currentTheme.name)
                .foregroundColor(.secondary)
        }
    }
}
```
**Test**: Theme option should appear for premium users

### Step 5.5: Update Settings Categories
**File**: `FlowMode/Views/Settings/TimerSettingsView.swift`
**Action**: Add theme section
**Find**: After the last setting in the view
**Add**:
```swift
if subscriptionService.subscriptionStatus.hasActiveAccess {
    Section("Appearance") {
        NavigationLink(destination: ThemeSelectionView()) {
            HStack {
                Text("Theme")
                Spacer()
                Text(themeService.currentTheme.name)
                    .foregroundColor(.secondary)
            }
        }
    }
}
```
**Test**: Theme section should appear in timer settings

## Phase 6: Additional Premium Themes

### Step 6.1: Add More Premium Themes
**File**: `FlowMode/Core/Services/ThemeProvider.swift`
**Action**: Add to defaultThemes array
**Add** after existing themes:
```swift
Theme(
    id: "forest",
    name: "Forest",
    isPremium: true,
    primaryRingColor: CodableColor(color: Color(hex: "27AE60")),
    secondaryRingColor: CodableColor(color: Color(hex: "229954")),
    ringBackgroundColor: CodableColor(color: Color(hex: "1E3A2A")),
    primaryTextColor: CodableColor(color: Color(hex: "E8F5E9")),
    secondaryTextColor: CodableColor(color: Color(hex: "A5D6A7")),
    backgroundColor: CodableColor(color: Color(hex: "0D2818")),
    useGradientBackground: true,
    gradientEndColor: CodableColor(color: Color(hex: "1A3A2A")),
    glowEffect: false,
    glowColor: nil,
    glowRadius: 0
),
Theme(
    id: "sunset",
    name: "Sunset",
    isPremium: true,
    primaryRingColor: CodableColor(color: Color(hex: "FF6B6B")),
    secondaryRingColor: CodableColor(color: Color(hex: "FFE66D")),
    ringBackgroundColor: CodableColor(color: Color(hex: "4A3C3C")),
    primaryTextColor: CodableColor(color: Color(hex: "FFF5F5")),
    secondaryTextColor: CodableColor(color: Color(hex: "FFB5B5")),
    backgroundColor: CodableColor(color: Color(hex: "2D1B1B")),
    useGradientBackground: true,
    gradientEndColor: CodableColor(color: Color(hex: "4A2C2C")),
    glowEffect: true,
    glowColor: CodableColor(color: Color(hex: "FF6B6B")),
    glowRadius: 8
),
Theme(
    id: "ocean",
    name: "Ocean",
    isPremium: true,
    primaryRingColor: CodableColor(color: Color(hex: "00BCD4")),
    secondaryRingColor: CodableColor(color: Color(hex: "00ACC1")),
    ringBackgroundColor: CodableColor(color: Color(hex: "1A3A4A")),
    primaryTextColor: CodableColor(color: Color(hex: "E0F7FA")),
    secondaryTextColor: CodableColor(color: Color(hex: "80DEEA")),
    backgroundColor: CodableColor(color: Color(hex: "0A1929")),
    useGradientBackground: true,
    gradientEndColor: CodableColor(color: Color(hex: "1A3A4A")),
    glowEffect: true,
    glowColor: CodableColor(color: Color(hex: "00BCD4")),
    glowRadius: 12
)
```
**Test**: Should have 5+ themes available

## Phase 7: Polish and Edge Cases

### Step 7.1: Add Theme Persistence Check
**File**: `FlowMode/Core/Services/ThemeService.swift`
**Action**: Add validation in init
**Find**: In init(), after setting currentTheme
**Add**:
```swift
// Validate theme exists
if !availableThemes.contains(where: { $0.id == timerService.settings.selectedThemeId }) {
    timerService.settings.selectedThemeId = "default"
    currentTheme = ThemeProvider.theme(withId: "default")
}
```
**Test**: Invalid theme ID should fallback to default

### Step 7.2: Add Paywall Alert for Locked Themes
**File**: `FlowMode/Views/Settings/ThemeSelectionView.swift`
**Action**: Add paywall sheet
**Find**: After `@Environment(\.dismiss)`
**Add**:
```swift
@State private var showingPaywall = false
```
**Find**: In ThemeRow action
**Replace** action content with:
```swift
if themeService.canSelectTheme(theme, subscriptionStatus: subscriptionService.subscriptionStatus) {
    themeService.selectTheme(theme)
    dismiss()
} else {
    showingPaywall = true
}
```
**Find**: After `.navigationTitle`
**Add**:
```swift
.sheet(isPresented: $showingPaywall) {
    TimerPaywallView()
        .environmentObject(subscriptionService)
}
```
**Test**: Locked themes should show paywall

### Step 7.3: Add Animation to Theme Changes
**File**: `FlowMode/Views/Timer/TimerView.swift`
**Action**: Add theme transition animation
**Find**: Color usage in views
**Add** `.animation(.easeInOut(duration: 0.3), value: themeService.currentTheme.id)`
**Test**: Theme changes should animate smoothly

### Step 7.4: Platform-Specific Adjustments
**File**: `FlowMode/Core/Models/CodableColor.swift`
**Action**: Fix macOS compatibility
**Find**: UIColor usage
**Replace** with platform-specific code:
```swift
#if os(iOS)
let uiColor = UIColor(color)
var r: CGFloat = 0
var g: CGFloat = 0
var b: CGFloat = 0
var a: CGFloat = 0
uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
#elseif os(macOS)
let nsColor = NSColor(color)
var r: CGFloat = 0
var g: CGFloat = 0
var b: CGFloat = 0
var a: CGFloat = 0
nsColor.getRed(&r, green: &g, blue: &b, alpha: &a)
#endif
```
**Test**: Should work on both iOS and macOS

## Phase 8: Testing & Verification

### Step 8.1: Test Theme Switching
**Actions**:
1. Launch app
2. Navigate to Settings → Timer → Theme
3. Select different themes
4. Verify colors update immediately
5. Verify selection persists after app restart
**Expected**: Theme changes apply instantly and persist

### Step 8.2: Test Premium Gating
**Actions**:
1. Disable subscription in debug settings
2. Try selecting premium theme
3. Verify paywall appears
4. Enable subscription
5. Verify premium themes unlock
**Expected**: Premium themes locked without subscription

### Step 8.3: Test Visual Effects
**Actions**:
1. Select theme with glow effect
2. Verify glow appears on timer
3. Select gradient background theme
4. Verify gradient renders correctly
**Expected**: All visual effects work as configured

### Step 8.4: Cross-Platform Testing
**Actions**:
1. Build for iOS
2. Test all themes
3. Build for macOS
4. Test all themes
5. Verify no platform-specific issues
**Expected**: Themes work identically on both platforms

### Step 8.5: Memory and Performance
**Actions**:
1. Switch themes rapidly
2. Monitor memory usage
3. Check for smooth animations
4. Verify no memory leaks
**Expected**: Smooth performance, no memory issues

## Success Criteria

- [ ] 5+ themes available (1 free, 4+ premium)
- [ ] Theme colors apply to all timer elements
- [ ] Settings persist across app launches
- [ ] Premium themes gated behind subscription
- [ ] Smooth animations on theme change
- [ ] Works on both iOS and macOS
- [ ] No memory leaks or performance issues
- [ ] Themes preview correctly in settings
- [ ] Paywall appears for locked themes
- [ ] Glow and gradient effects work properly

## Notes for Implementation

1. **Test each step** before moving to the next
2. **Commit after each phase** for easy rollback
3. **Run on both platforms** after major changes
4. **Check subscription status** throughout implementation
5. **Verify UserDefaults** saves theme selection
6. **Test with different color schemes** (light/dark mode)
7. **Ensure accessibility** - verify contrast ratios

## Potential Enhancements (Future)
- Custom theme creator
- Import/export themes
- Seasonal theme packs
- Dynamic themes (time-based)
- Theme sharing between devices
- Animation effects per theme
