//
//  TimerService.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import Foundation
import Combine

class TimerService: ObservableObject {
    @Published var timerState: TimerState = .idle
    @Published var elapsedSeconds: Int = 0
    @Published var remainingPauseSeconds: Int = 0
    @Published var settings: TimerSettings = TimerSettings()
    
    private var timer: Timer?
    private var startTime: Date?
    private var pauseEndDate: Date?
    
    init() {
        self.settings = Self.loadSettings()
        
        // Set up didSet behavior manually since we can't use it in the property declaration
        self.$settings
            .dropFirst() // Skip the initial value
            .sink { [weak self] _ in
                self?.saveSettings()
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    var progressPercentage: CGFloat {
        switch timerState {
        case .working, .workPaused:
            if settings.maxWorkTimeEnabled {
                let maxSeconds = settings.maxWorkTimeMinutes * 60
                return CGFloat(elapsedSeconds) / CGFloat(maxSeconds)
            } else {
                // No max time set, show indeterminate progress (always 0)
                return 0.0
            }
        case .workCompleted, .breaking, .breakPaused:
            if remainingPauseSeconds > 0 {
                let totalPauseSeconds = elapsedSeconds * settings.selectedPausePercentage / 100
                return CGFloat(remainingPauseSeconds) / CGFloat(totalPauseSeconds)
            }
            return 0.0
        default:
            return 0.0
        }
    }
    
    func startWorkTimer() {
        timerState = .working
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateElapsedTime()
        }
        
        // Schedule max work time notification if enabled
        if settings.maxWorkTimeEnabled && settings.notifyMaxWorkTime {
            let timeInterval = TimeInterval(settings.maxWorkTimeMinutes * 60)
            NotificationService.shared.scheduleNotification(
                title: "Work Session Complete",
                body: "Time for a break! You've reached your maximum work time.",
                timeInterval: timeInterval,
                identifier: "maxWorkTime"
            )
        }
    }
    
    func pauseWorkTimer() {
        timerState = .workPaused
        timer?.invalidate()
        timer = nil
    }
    
    func resumeWorkTimer() {
        timerState = .working
        startTime = Date().addingTimeInterval(-Double(elapsedSeconds))
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateElapsedTime()
        }
    }
    
    func completeWorkTimer() {
        completeWorkTimer(playSound: false)
    }
    
    private func completeWorkTimer(playSound: Bool) {
        timerState = .workCompleted
        timer?.invalidate()
        timer = nil
        
        let pauseSeconds = elapsedSeconds * settings.selectedPausePercentage / 100
        remainingPauseSeconds = pauseSeconds
        
        // Only play sound if this was triggered automatically (max time reached)
        if playSound, let soundName = settings.maxWorkTimeSound {
            #if os(iOS)
            SoundService.playSound(named: soundName, continuous: true)
            #else
            SoundService.playSound(named: soundName)
            #endif
        }
    }
    
    func startBreakTimer() {
        timerState = .breaking
        pauseEndDate = Date().addingTimeInterval(Double(remainingPauseSeconds))
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateBreakTime()
        }
        
        // Schedule break complete notification if enabled
        if settings.notifyPauseComplete && remainingPauseSeconds > 0 {
            NotificationService.shared.scheduleNotification(
                title: "Break Complete",
                body: "Your break is over. Ready to start working again?",
                timeInterval: TimeInterval(remainingPauseSeconds),
                identifier: "breakComplete"
            )
        }
    }
    
    func resetTimer() {
        timerState = .idle
        timer?.invalidate()
        timer = nil
        startTime = nil
        pauseEndDate = nil
        elapsedSeconds = 0
        remainingPauseSeconds = 0
        
        // Cancel any pending notifications
        NotificationService.shared.cancelAllNotifications()
        
        // Stop any continuous sounds
        #if os(iOS)
        SoundService.stopContinuousSound()
        #endif
    }
    
    func stopWorkTimer() {
        timerState = .idle
        timer?.invalidate()
        timer = nil
        startTime = nil
        elapsedSeconds = 0
        remainingPauseSeconds = 0
    }
    
    private func updateElapsedTime() {
        guard let startTime = startTime else { return }
        elapsedSeconds = Int(Date().timeIntervalSince(startTime))
        
        // Check if max work time is reached
        if settings.maxWorkTimeEnabled {
            let maxWorkTimeSeconds = settings.maxWorkTimeMinutes * 60
            if elapsedSeconds >= maxWorkTimeSeconds {
                completeWorkTimer(playSound: true)
            }
        }
    }
    
    private func updateBreakTime() {
        guard let pauseEndDate = pauseEndDate else { return }
        remainingPauseSeconds = max(0, Int(pauseEndDate.timeIntervalSince(Date())))
        
        if remainingPauseSeconds <= 0 {
            completeBreakTimer()
        }
    }
    
    private func completeBreakTimer() {
        timerState = .idle
        timer?.invalidate()
        timer = nil
        pauseEndDate = nil
        elapsedSeconds = 0
        remainingPauseSeconds = 0
        
        // Play pause complete sound
        if let soundName = settings.pauseCompleteSound {
            #if os(iOS)
            SoundService.playSound(named: soundName, continuous: true)
            #else
            SoundService.playSound(named: soundName)
            #endif
        }
    }
    
    private static func loadSettings() -> TimerSettings {
        if let data = UserDefaults.standard.data(forKey: "TimerSettings"),
           let settings = try? JSONDecoder().decode(TimerSettings.self, from: data) {
            return settings
        }
        return TimerSettings()
    }
    
    private func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: "TimerSettings")
        }
    }
}