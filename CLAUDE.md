# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FlowMode is a cross-platform SwiftUI productivity timer app implementing the Flowmodoro technique. The app targets iOS 17.6+ and macOS 14.6+ with subscription-based monetization through StoreKit 2.


### Target Configuration
- **iOS Target**: FlowMode (iOS 17.6+)
- **macOS Target**: FlowMode (macOS 14.6+)
- **Bundle ID**: `de.synkvideo.FlowMode`
- **Team**: DY23YHPAZC

## Architecture Overview

### Core Pattern: MVVM with Environment Objects
The app uses SwiftUI's reactive architecture with services acting as ObservableObject ViewModels. State flows through `@StateObject` and `@EnvironmentObject` dependency injection.

### Service Layer Architecture
- **TimerService**: Central state management for timer functionality, settings persistence via UserDefaults
- **SubscriptionService**: StoreKit 2 integration with 7-day trial and monthly subscription (`de.synkmedia.FlowMode.monthly`)
- **NotificationService**: Local notifications for work/break alerts with platform-specific handling
- **SoundService**: System sound playback with extensive iOS sound library (54+ sounds) and platform-specific implementations
- **BackgroundTaskService**: iOS-only background timer continuity and lifecycle management

### Cross-Platform Strategy
Uses conditional compilation (`#if os(macOS)` / `#if os(iOS)`) for platform-specific UI and functionality:
- **iOS**: TabView navigation, background tasks, haptic feedback, continuous sound alarms
- **macOS**: Toolbar-based settings, system sound integration, window management

## Key State Management

### Timer States
```swift
enum TimerState {
    case idle, working, workPaused, workCompleted, breaking, breakPaused
}
```

### Settings Persistence
TimerSettings are automatically persisted to UserDefaults via Combine publishers. Settings include pause percentage (10-50%), max work time, notification preferences, and sound selections.

### Subscription Logic
- 7-day free trial with automatic expiration
- Premium features gated behind `subscriptionStatus.hasActiveAccess`
- Debug controls available in Settings for testing subscription states

## Flowmodoro Algorithm Implementation

The core timer logic calculates break time as a percentage of work time:
- Work session tracking with optional maximum duration
- Break time = work_duration × pause_percentage / 100
- Dual progress rings: inner (work progress), outer (accumulated pause time)
- Background time handling with user notification on extended absence

## Subscription Integration

### StoreKit 2 Implementation
- Product loading and purchase flow with receipt verification
- Transaction listener for subscription updates
- Trial management with local state tracking
- Premium feature gating throughout the app

### Feature Gating
Premium features are controlled via `SubscriptionService.subscriptionStatus.hasActiveAccess` and include unlimited sessions, custom sounds, advanced notifications, and premium themes.

## Platform-Specific Considerations

### iOS-Specific Features
- Background task management to maintain timer accuracy
- Continuous sound playback for alarms using AVAudioPlayer
- UIImpactFeedbackGenerator for haptic feedback
- TabView-based navigation structure

### macOS-Specific Features
- Toolbar-based settings access instead of tab navigation
- NSWorkspace integration for external URL opening
- System AudioToolbox for sound playback
- Modal settings presentation

## Testing Strategy

- **Unit Tests**: Basic test structure in `FlowModeTests.swift`
- **UI Tests**: Launch tests and interaction tests in `FlowModeUITests.swift`
- **Subscription Testing**: Debug controls in Settings for trial manipulation
- **Cross-Platform Testing**: Verify functionality on both iOS and macOS targets

## Important Implementation Notes

### Timer Accuracy
Background time is calculated and adjusted when returning from background. Extended background periods trigger user notification for timer state decisions.

### Sound Management
Extensive iOS sound library with hierarchical organization (Alerts, Call Tones, etc.). macOS uses system sounds with fallback handling for missing resources.

### Memory Management
Services use proper `[weak self]` capture in closures and Combine publishers. Background tasks are properly cleaned up on app lifecycle changes.

### Error Handling
Subscription errors are user-facing with specific error types. Settings persistence has fallback to defaults on corruption. Sound playback fails gracefully with console logging.

## Recent Development Summary

### Enhanced Timer Controls (Latest Update)
**Key Features Added:**
- **Interactive Timer Gestures**: Timer circle now supports tap (play/pause), double-tap (reset), and long-press (complete work session)
- **Break Timer Controls**: Added pause/resume functionality for break timers (`pauseBreakTimer()` and `resumeBreakTimer()` methods in TimerService)
- **Settings Integration**: New "Show Timer Controls" toggle in settings to hide/show traditional control buttons
- **Cross-Platform Enhancements**:
  - **iOS**: Haptic feedback for double-tap and reset actions
  - **macOS**: NSSound.beep() audio feedback, Space bar keyboard shortcut for play/pause
- **Visual Feedback**: Timer circle animates on interaction with scale effect and press state management

**Technical Implementation:**
- Fixed gesture handling order in TimerView.swift to prevent tap gesture conflicts
- Timer gestures processed before drag gesture to ensure proper functionality
- Added platform-specific conditional compilation for feedback mechanisms
- Enhanced TimerSettings model with `showTimerControls` boolean property

**File Locations:**
- Enhanced timer logic: `FlowMode/Views/Timer/TimerView.swift`
- Break timer methods: `FlowMode/Core/Services/TimerService.swift:163-189`
- Settings UI: `FlowMode/Views/Settings/SettingsView.swift:297-301`
- Timer settings model: `FlowMode/Core/Models/TimerSettings.swift:20`

## Current Development Status

The app is production-ready with complete timer functionality, subscription system, cross-platform support, and premium feature gating. Latest enhancements include:

### Premium Theme System & Settings Integration (Latest Update)
**Key Features Added:**
- **5 Beautiful Themes**: Classic (free), Midnight, Forest, Sunset, and Ocean (premium)
- **Visual Customization**: Ring colors, text colors, backgrounds, gradients, and glow effects
- **Premium Gating**: Platform-specific paywall integration (sheet on iOS/macOS)
- **Automatic Fallback**: Switches to Classic theme when subscription expires
- **Cross-Platform UI**: Grid layout on macOS, list on iOS with consistent theme cards
- **Dark Mode Support**: Classic theme uses semantic colors for automatic adaptation
- **Comprehensive Settings Theming**: All settings views now use theme-aware backgrounds
- **Debug Controls**: Dedicated debug settings page with comprehensive subscription testing
- **macOS Native Integration**: Borderless window with native settings access

**Technical Implementation:**
- Theme model with CodableColor for cross-platform color encoding
- ThemeService with Combine-based subscription status monitoring
- ThemeProvider with static theme definitions and validation
- Platform-specific paywall presentation matching timer behavior
- Smooth 0.3-second animations for theme transitions
- Robust persistence with fallback validation
- `themedBackground()` view modifier for consistent theme application
- Cross-platform background color compatibility fixes

**File Locations:**
- Core models: `FlowMode/Core/Models/Theme.swift`, `CodableColor.swift`, `SettingsCategory.swift`
- Service layer: `FlowMode/Core/Services/ThemeService.swift`, `ThemeProvider.swift`
- UI components: `FlowMode/Views/Settings/ThemeSelectionView.swift`, `ThemeCard.swift`, `ThemePreview.swift`, `DebugSettingsView.swift`
- Utilities: `FlowMode/Core/Utilities/Color+Extensions.swift`, `View+Extensions.swift`
- Enhanced views: `FlowMode/Views/Settings/SettingsView.swift`, `AboutSettingsView.swift`, `SubscriptionView.swift`

### Visual Timer Feedback
**Key Features Added:**
- **Timer Dimming**: Timer circle dims to 50% opacity when idle or work paused
- **Smooth Animations**: 0.3-second easing animation for visual state changes
- **Enhanced UX**: Clear visual feedback for timer states

### NavigationSplitView Settings Interface
**Key Features Added:**
- **macOS**: Dedicated Settings window with Cmd+, support, resizable interface, and always-visible sidebar
- **iOS**: NavigationSplitView-based settings with organized categories (Timer, Theme, Notifications, Subscription, About, Debug)
- **Cross-Platform**: Consistent feature set with platform-appropriate UI patterns
- **Clean Interface**: Streamlined design with theme-aware backgrounds throughout
- **Native macOS Window**: Borderless title bar with seamless theme integration

**Technical Implementation:**
- Created SettingsCategory enum for type-safe navigation
- Implemented modular setting views: TimerSettingsView, NotificationSettingsView, AboutSettingsView, DebugSettingsView
- Enhanced cross-platform Settings scene with proper window configuration
- Theme-aware sidebar and detail views with consistent visual design
- Native macOS settings integration via Environment openSettings

**Previous Enhancements:**
- Interactive timer controls with cross-platform gesture support (tap, double-tap, long-press)
- Break timer pause/resume functionality
- Platform-specific feedback (haptics, sound, keyboard shortcuts)

## Development Workflow Guidelines

### CODING PROTOCOL 

- Write the absolute minimum code required
- No sweeping changes
- No unrelated edits - focus on just the task you're on
- Make code precise, modular, testable
- Don't break existing functionality
- If I need to do anything tell me clearly
### Branch Management
**IMPORTANT**: When switching branches, always ensure CLAUDE.md is synchronized with the actual codebase features. Each branch should have an accurate CLAUDE.md that reflects the current state of features and implementation details.

### Testing Protocol
- **Manual Testing**: User handles manual testing of builds and functionality
- **Build Verification**: User responsibility for build verification and device testing

### Development Memory
- **i test and build**: General task of verifying application functionality and preparing builds for testing and distribution
