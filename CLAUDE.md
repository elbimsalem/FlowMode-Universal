# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FlowMode is a cross-platform SwiftUI productivity timer app implementing the Flowmodoro technique. The app targets iOS 17.6+ and macOS 14.6+ with subscription-based monetization through StoreKit 2.

## Development Commands

### Building & Running
```bash
# Open in Xcode (primary development environment)
open FlowMode.xcodeproj

# Command line builds
xcodebuild -project FlowMode.xcodeproj -scheme FlowMode -configuration Debug build
xcodebuild -project FlowMode.xcodeproj -scheme FlowMode -configuration Release build

# Run tests
xcodebuild -project FlowMode.xcodeproj -scheme FlowMode test
# Or use Cmd+U in Xcode
```

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
Premium features are controlled via `SubscriptionService.subscriptionStatus.hasActiveAccess` and include unlimited sessions, custom sounds, and advanced notifications.

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

The app is production-ready with complete timer functionality, subscription system, cross-platform support, and premium feature gating. Latest enhancements include interactive timer controls with cross-platform gesture support and improved user experience.