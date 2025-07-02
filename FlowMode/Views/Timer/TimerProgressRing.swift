//
//  TimerProgressRing.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct TimerProgressRing: View {
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var timerService: TimerService
    
    // Legacy properties for backwards compatibility
    let progress: CGFloat
    let timerState: TimerState
    let pauseProgress: CGFloat
    
    private let strokeWidth: CGFloat = 8
    private let baseRingSize: CGFloat = 200
    private let ringSpacing: CGFloat = 20
    private let minRingSize: CGFloat = 80
    
    var body: some View {
        ZStack {
            // Max work time background rings (only during work states)
            if timerService.settings.maxWorkTimeEnabled && 
               (timerService.timerState == .working || timerService.timerState == .workPaused || timerService.timerState == .idle) {
                ForEach(0..<maxWorkTimeRingCount, id: \.self) { ringIndex in
                    if let maxProgress = maxWorkTimeProgressForRing(ringIndex) {
                        let ringSize = max(minRingSize, baseRingSize - CGFloat(ringIndex) * ringSpacing)
                        Circle()
                            .trim(from: 0, to: maxProgress)
                            .stroke(themeService.currentTheme.ringBackgroundColor.color, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                            .frame(width: ringSize, height: ringSize)
                            .rotationEffect(.degrees(-90))
                    }
                }
            }
            
            // Expected pause time background rings (when enabled and max work time is set)
            if timerService.settings.maxWorkTimeEnabled && timerService.settings.showExpectedPauseRings {
                ForEach(0..<expectedPauseRingCount, id: \.self) { ringIndex in
                    if let expectedProgress = expectedPauseProgressForRing(ringIndex) {
                        let ringSize = baseRingSize + CGFloat(ringIndex + 1) * ringSpacing
                        Circle()
                            .trim(from: 0, to: expectedProgress)
                            .stroke(themeService.currentTheme.ringBackgroundColor.color, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                            .frame(width: ringSize, height: ringSize)
                            .rotationEffect(.degrees(-90))
                    }
                }
            }
            
            // Work rings (exactly on top of max work time rings)
            ForEach(0..<timerService.workRingCount, id: \.self) { ringIndex in
                let ringSize = max(minRingSize, baseRingSize - CGFloat(ringIndex) * ringSpacing)
                let currentWorkRingIndex = timerService.elapsedSeconds / (60 * 60) // Which ring we're currently filling
                
                // Work progress ring - only show for completed rings and current active ring
                if ringIndex < currentWorkRingIndex {
                    // Completed rings - fill entire 60 minutes
                    Circle()
                        .trim(from: 0, to: 1.0)
                        .stroke(workRingColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                        .frame(width: ringSize, height: ringSize)
                        .rotationEffect(.degrees(-90))
                } else if ringIndex == currentWorkRingIndex {
                    // Current active ring - fill based on progress within this 60-minute segment
                    Circle()
                        .trim(from: 0, to: timerService.workRingProgress)
                        .stroke(workRingColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                        .frame(width: ringSize, height: ringSize)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.3), value: timerService.workRingProgress)
                }
            }
            
            // Pause/Break rings - show accumulated break time during work, actual break time during breaks
            if timerService.pauseRingCount > 0 {
                ForEach(0..<timerService.pauseRingCount, id: \.self) { ringIndex in
                    let ringSize = baseRingSize + CGFloat(ringIndex + 1) * ringSpacing
                    
                    if timerService.timerState == .working || timerService.timerState == .workPaused {
                        // During work: show accumulated break time being earned
                        let earnedBreakSeconds = timerService.elapsedSeconds * timerService.settings.selectedPausePercentage / 100
                        let currentEarnedRingIndex = earnedBreakSeconds / (60 * 60)
                        
                        if ringIndex < currentEarnedRingIndex {
                            // Completed earned break rings
                            Circle()
                                .trim(from: 0, to: 1.0)
                                .stroke(themeService.currentTheme.secondaryRingColor.color.opacity(0.6), style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                                .frame(width: ringSize, height: ringSize)
                                .rotationEffect(.degrees(-90))
                        } else if ringIndex == currentEarnedRingIndex {
                            // Current earned break ring
                            let progressInCurrentRing = CGFloat(earnedBreakSeconds % (60 * 60)) / CGFloat(60 * 60)
                            Circle()
                                .trim(from: 0, to: progressInCurrentRing)
                                .stroke(themeService.currentTheme.secondaryRingColor.color.opacity(0.6), style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                                .frame(width: ringSize, height: ringSize)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 0.3), value: progressInCurrentRing)
                        }
                    } else if timerService.timerState == .breaking || timerService.timerState == .breakPaused {
                        // During break: show actual break time consumption
                        let elapsedBreakSeconds = timerService.elapsedSeconds * timerService.settings.selectedPausePercentage / 100 - timerService.remainingPauseSeconds
                        let currentBreakRingIndex = elapsedBreakSeconds / (60 * 60)
                        
                        if ringIndex < currentBreakRingIndex {
                            // Completed break rings
                            Circle()
                                .trim(from: 0, to: 1.0)
                                .stroke(themeService.currentTheme.secondaryRingColor.color, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                                .frame(width: ringSize, height: ringSize)
                                .rotationEffect(.degrees(-90))
                        } else if ringIndex == currentBreakRingIndex {
                            // Current active break ring
                            Circle()
                                .trim(from: 0, to: timerService.pauseRingProgress)
                                .stroke(themeService.currentTheme.secondaryRingColor.color, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                                .frame(width: ringSize, height: ringSize)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 0.3), value: timerService.pauseRingProgress)
                        }
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: themeService.currentTheme.id)
    }
    
    private var workRingColor: Color {
        switch timerService.timerState {
        case .working, .workPaused:
            return themeService.currentTheme.primaryRingColor.color
        case .workCompleted, .breaking, .breakPaused:
            return themeService.currentTheme.secondaryRingColor.color
        default:
            return themeService.currentTheme.ringBackgroundColor.color
        }
    }
    
    private var maxWorkTimeRingCount: Int {
        guard timerService.settings.maxWorkTimeEnabled else { return 0 }
        let maxWorkTimeSeconds = timerService.settings.maxWorkTimeMinutes * 60
        let secondsPerRing = 60 * 60
        return (maxWorkTimeSeconds + secondsPerRing - 1) / secondsPerRing // Ceiling division
    }
    
    private var expectedPauseRingCount: Int {
        guard timerService.settings.maxWorkTimeEnabled else { return 0 }
        let maxWorkTimeSeconds = timerService.settings.maxWorkTimeMinutes * 60
        let expectedBreakSeconds = maxWorkTimeSeconds * timerService.settings.selectedPausePercentage / 100
        let secondsPerRing = 60 * 60
        return max(1, (expectedBreakSeconds + secondsPerRing - 1) / secondsPerRing) // Ceiling division
    }
    
    private var maxBreakTimeRingCount: Int {
        let totalBreakSeconds = timerService.elapsedSeconds * timerService.settings.selectedPausePercentage / 100
        let secondsPerRing = 60 * 60
        return max(1, (totalBreakSeconds + secondsPerRing - 1) / secondsPerRing) // Ceiling division
    }
    
    private func maxWorkTimeProgressForRing(_ ringIndex: Int) -> CGFloat? {
        guard timerService.settings.maxWorkTimeEnabled else { return nil }
        let maxWorkTimeSeconds = timerService.settings.maxWorkTimeMinutes * 60
        let secondsPerRing = 60 * 60 // 3600 seconds per ring
        
        // Calculate which rings are affected by max work time
        let totalMaxRings = (maxWorkTimeSeconds + secondsPerRing - 1) / secondsPerRing // Ceiling division
        
        if ringIndex >= totalMaxRings {
            return nil // This ring is beyond max work time
        }
        
        // Calculate progress for this specific ring
        let ringStartSeconds = ringIndex * secondsPerRing
        let ringEndSeconds = (ringIndex + 1) * secondsPerRing
        
        if maxWorkTimeSeconds >= ringEndSeconds {
            // This ring should be completely filled
            return 1.0
        } else if maxWorkTimeSeconds > ringStartSeconds {
            // This ring is partially filled
            let progressInRing = maxWorkTimeSeconds - ringStartSeconds
            return CGFloat(progressInRing) / CGFloat(secondsPerRing)
        }
        
        return nil
    }
    
    private func expectedPauseProgressForRing(_ ringIndex: Int) -> CGFloat? {
        guard timerService.settings.maxWorkTimeEnabled else { return nil }
        let maxWorkTimeSeconds = timerService.settings.maxWorkTimeMinutes * 60
        let expectedBreakSeconds = maxWorkTimeSeconds * timerService.settings.selectedPausePercentage / 100
        let secondsPerRing = 60 * 60 // 3600 seconds per ring
        
        // Calculate which rings are affected by expected pause time
        let totalExpectedRings = (expectedBreakSeconds + secondsPerRing - 1) / secondsPerRing // Ceiling division
        
        if ringIndex >= totalExpectedRings {
            return nil // This ring is beyond expected pause time
        }
        
        // Calculate progress for this specific ring
        let ringStartSeconds = ringIndex * secondsPerRing
        let ringEndSeconds = (ringIndex + 1) * secondsPerRing
        
        if expectedBreakSeconds >= ringEndSeconds {
            // This ring should be completely filled
            return 1.0
        } else if expectedBreakSeconds > ringStartSeconds {
            // This ring is partially filled
            let progressInRing = expectedBreakSeconds - ringStartSeconds
            return CGFloat(progressInRing) / CGFloat(secondsPerRing)
        }
        
        return nil
    }
}