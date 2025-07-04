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
    @EnvironmentObject var themeService: ThemeService
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var isPressed = false
    @State private var isAdjustingPausePercentage = false
    @State private var isAdjustingMaxWorkTime = false
    @State private var lastDragValue: CGFloat = 0
    @State private var accumulatedPauseChange: Double = 0
    @State private var accumulatedMaxTimeChange: Double = 0
    @State private var tempPausePercentage: Int = 25
    @State private var tempMaxWorkTime: Int = 120
    #if os(macOS)
    @Environment(\.openSettings) private var openSettings
    #endif
    
    var body: some View {
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
                .if(themeService.currentTheme.glowEffect) { view in
                    view.shadow(
                        color: themeService.currentTheme.glowColor?.color ?? .clear,
                        radius: themeService.currentTheme.glowRadius
                    )
                }
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
                    Text("Break: \(tempPausePercentage)%")
                        .font(isAdjustingPausePercentage ? .body : .caption)
                        .fontWeight(isAdjustingPausePercentage ? .medium : .regular)
                        .foregroundColor(isAdjustingPausePercentage ? themeService.currentTheme.primaryRingColor.color : .secondary)
                        .animation(.easeInOut(duration: 0.2), value: isAdjustingPausePercentage)
                        .animation(.easeInOut(duration: 0.1), value: tempPausePercentage)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    handlePausePercentageAdjustment(value)
                                }
                                .onEnded { _ in
                                    finishPausePercentageAdjustment()
                                }
                        )
                    
                    if timerService.settings.maxWorkTimeEnabled {
                        Text("Max: \(tempMaxWorkTime)m")
                            .font(isAdjustingMaxWorkTime ? .body : .caption)
                            .fontWeight(isAdjustingMaxWorkTime ? .medium : .regular)
                            .foregroundColor(isAdjustingMaxWorkTime ? themeService.currentTheme.primaryRingColor.color : .secondary)
                            .animation(.easeInOut(duration: 0.2), value: isAdjustingMaxWorkTime)
                            .animation(.easeInOut(duration: 0.1), value: tempMaxWorkTime)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        handleMaxWorkTimeAdjustment(value)
                                    }
                                    .onEnded { _ in
                                        finishMaxWorkTimeAdjustment()
                                    }
                            )
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
            
            // Settings button overlay - positioned independently
            GeometryReader { geometry in
                let isLandscape = geometry.size.width > geometry.size.height
                
                #if os(iOS)
                VStack {
                    if isLandscape {
                        // Landscape: Position at bottom right
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                showingSettings = true
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                    .foregroundColor(themeService.currentTheme.secondaryTextColor.color)
                                    .opacity(0.7)
                            }
                            .buttonStyle(.plain)
                            .padding(.trailing, 40)
                        }
                        .padding(.bottom, 40)
                    } else {
                        // Portrait: Position at the bottom center
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                showingSettings = true
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                    .foregroundColor(themeService.currentTheme.secondaryTextColor.color)
                                    .opacity(0.7)
                            }
                            .buttonStyle(.plain)
                            Spacer()
                        }
                        .padding(.bottom, 40)
                    }
                }
                #else
                // macOS: Keep existing positioning
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            openSettings()
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(themeService.currentTheme.secondaryTextColor.color)
                                .opacity(0.7)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    .padding(.bottom, 40)
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            // Could add hover effect here if desired
                        }
                    }
                }
                #endif
            }
        }
        .onAppear {
            tempPausePercentage = timerService.settings.selectedPausePercentage
            tempMaxWorkTime = timerService.settings.maxWorkTimeMinutes
        }
        .animation(.easeInOut(duration: 0.3), value: themeService.currentTheme.id)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isAdjustingPausePercentage)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isAdjustingMaxWorkTime)
        .sheet(isPresented: $showingPaywall) {
            TimerPaywallView()
                .environmentObject(subscriptionService)
        }
        #if os(iOS)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(timerService)
                .environmentObject(subscriptionService)
                .environmentObject(themeService)
        }
        #endif
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
    
    private func handlePausePercentageAdjustment(_ value: DragGesture.Value) {
        if !isAdjustingPausePercentage {
            isAdjustingPausePercentage = true
            lastDragValue = value.translation.width
            accumulatedPauseChange = 0
            tempPausePercentage = timerService.settings.selectedPausePercentage
            
            #if os(iOS)
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            #endif
            return
        }
        
        // Calculate delta from last frame
        let delta = value.translation.width - lastDragValue
        let sensitivity: Double = 0.3
        
        // Accumulate the change with sensitivity
        accumulatedPauseChange += Double(delta) * sensitivity
        
        // Apply accumulated change when it exceeds the snap increment (5)
        let snapIncrement: Double = 5.0
        if abs(accumulatedPauseChange) >= snapIncrement {
            let increments = Int(accumulatedPauseChange / snapIncrement)
            let change = Double(increments) * snapIncrement
            
            // Update value with bounds checking
            let newPercentage = max(10, min(50, timerService.settings.selectedPausePercentage + Int(change)))
            
            if newPercentage != tempPausePercentage {
                tempPausePercentage = newPercentage
                timerService.settings.selectedPausePercentage = newPercentage
                
                #if os(iOS)
                let selectionFeedback = UISelectionFeedbackGenerator()
                selectionFeedback.selectionChanged()
                #endif
            }
            
            // Reset accumulated change by the amount we used
            accumulatedPauseChange -= change
        }
        
        lastDragValue = value.translation.width
    }
    
    private func finishPausePercentageAdjustment() {
        withAnimation(.easeOut(duration: 0.3)) {
            isAdjustingPausePercentage = false
        }
        accumulatedPauseChange = 0
        lastDragValue = 0
        
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        #endif
    }
    
    private func handleMaxWorkTimeAdjustment(_ value: DragGesture.Value) {
        if !isAdjustingMaxWorkTime {
            isAdjustingMaxWorkTime = true
            lastDragValue = value.translation.width
            accumulatedMaxTimeChange = 0
            tempMaxWorkTime = timerService.settings.maxWorkTimeMinutes
            
            #if os(iOS)
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            #endif
            return
        }
        
        // Calculate delta from last frame
        let delta = value.translation.width - lastDragValue
        let sensitivity: Double = 0.5
        
        // Accumulate the change with sensitivity
        accumulatedMaxTimeChange += Double(delta) * sensitivity
        
        // Apply accumulated change when it exceeds the snap increment (5)
        let snapIncrement: Double = 5.0
        if abs(accumulatedMaxTimeChange) >= snapIncrement {
            let increments = Int(accumulatedMaxTimeChange / snapIncrement)
            let change = Double(increments) * snapIncrement
            
            // Update value with bounds checking
            let newMaxTime = max(15, min(480, timerService.settings.maxWorkTimeMinutes + Int(change)))
            
            if newMaxTime != tempMaxWorkTime {
                tempMaxWorkTime = newMaxTime
                timerService.settings.maxWorkTimeMinutes = newMaxTime
                
                #if os(iOS)
                let selectionFeedback = UISelectionFeedbackGenerator()
                selectionFeedback.selectionChanged()
                #endif
            }
            
            // Reset accumulated change by the amount we used
            accumulatedMaxTimeChange -= change
        }
        
        lastDragValue = value.translation.width
    }
    
    private func finishMaxWorkTimeAdjustment() {
        withAnimation(.easeOut(duration: 0.3)) {
            isAdjustingMaxWorkTime = false
        }
        accumulatedMaxTimeChange = 0
        lastDragValue = 0
        
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        #endif
    }
}