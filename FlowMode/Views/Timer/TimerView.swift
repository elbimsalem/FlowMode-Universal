//
//  TimerView.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var timerService: TimerService
    @EnvironmentObject var subscriptionService: SubscriptionService
    @State private var showingPaywall = false
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                ZStack {
                    TimerProgressRing(
                        progress: timerService.progressPercentage,
                        timerState: timerService.timerState,
                        pauseProgress: timerService.pauseProgressPercentage
                    )
                    
                    TimerDisplayView(
                        seconds: displaySeconds,
                        timerState: timerService.timerState,
                        useStackedDisplay: timerService.settings.useStackedTimeDisplay
                    )
                }
                .frame(width: 250, height: 250)
                .contentShape(Circle())
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .opacity(timerService.timerState == .workPaused || timerService.timerState == .idle ? 0.5 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: timerService.timerState == .workPaused || timerService.timerState == .idle)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
                .onTapGesture(count: 2) {
                    handleTimerDoubleTap()
                }
                .onTapGesture {
                    handleTimerTap()
                }
                .onLongPressGesture(minimumDuration: 1.0) {
                    handleTimerLongPress()
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !isPressed {
                                isPressed = true
                            }
                        }
                        .onEnded { _ in
                            isPressed = false
                        }
                )
                
                HStack(spacing: 20) {
                    Text("Break: \(timerService.settings.selectedPausePercentage)%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if timerService.settings.maxWorkTimeEnabled {
                        Text("Max: \(timerService.settings.maxWorkTimeMinutes)m")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                #if os(iOS)
                if SoundService.isPlayingContinuousSound {
                    Button("Stop Alarm") {
                        SoundService.stopContinuousSound()
                    }
                    .foregroundColor(.red)
                    .font(.headline)
                }
                #endif
            }
            
            if timerService.settings.showTimerControls {
                TimerControlsView(
                    timerState: timerService.timerState,
                    onPlayPause: handlePlayPause,
                    onComplete: handleComplete,
                    onReset: handleReset,
                    isEnabled: subscriptionService.subscriptionStatus.hasActiveAccess
                )
            }
        }
        .sheet(isPresented: $showingPaywall) {
            TimerPaywallView()
                .environmentObject(subscriptionService)
        }
        #if os(macOS)
        .background(
            Button("") {
                handleTimerTap()
            }
            .keyboardShortcut(.space, modifiers: [])
            .opacity(0)
        )
        #endif
    }
    
    private var displaySeconds: Int {
        switch timerService.timerState {
        case .workCompleted, .breaking, .breakPaused:
            return timerService.remainingPauseSeconds
        default:
            return timerService.elapsedSeconds
        }
    }
    
    private func handleTimerTap() {
        guard subscriptionService.subscriptionStatus.hasActiveAccess else {
            showingPaywall = true
            return
        }
        
        switch timerService.timerState {
        case .idle:
            timerService.startWorkTimer()
        case .working:
            timerService.pauseWorkTimer()
        case .workPaused:
            timerService.resumeWorkTimer()
        case .workCompleted:
            timerService.startBreakTimer()
        case .breaking:
            timerService.pauseBreakTimer()
        case .breakPaused:
            timerService.resumeBreakTimer()
        }
    }
    
    private func handleTimerLongPress() {
        guard subscriptionService.subscriptionStatus.hasActiveAccess else {
            showingPaywall = true
            return
        }
        
        switch timerService.timerState {
        case .working, .workPaused:
            timerService.completeWorkTimer()
        default:
            break
        }
    }
    
    private func handleTimerDoubleTap() {
        guard subscriptionService.subscriptionStatus.hasActiveAccess else {
            showingPaywall = true
            return
        }
        
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        #elseif os(macOS)
        if let soundName = timerService.settings.doubleTapFeedbackSound {
            NSSound(named: soundName)?.play()
        }
        #endif
        timerService.resetTimer()
    }
    
    private func handlePlayPause() {
        handleTimerTap()
    }
    
    private func handleComplete() {
        guard subscriptionService.subscriptionStatus.hasActiveAccess else {
            showingPaywall = true
            return
        }
        
        switch timerService.timerState {
        case .working, .workPaused:
            timerService.completeWorkTimer()
        default:
            break
        }
    }
    
    private func handleReset() {
        guard subscriptionService.subscriptionStatus.hasActiveAccess else {
            showingPaywall = true
            return
        }
        
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        #elseif os(macOS)
        if let soundName = timerService.settings.doubleTapFeedbackSound {
            NSSound(named: soundName)?.play()
        }
        #endif
        timerService.resetTimer()
    }
}