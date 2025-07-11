//
//  BackgroundTaskService.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import Foundation
import Combine
#if os(iOS)
import UIKit

class BackgroundTaskService: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private weak var timerService: TimerService?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var backgroundEntryTime: Date?
    
    init() {
        setupNotificationObservers()
    }
    
    func setTimerService(_ timerService: TimerService) {
        self.timerService = timerService
    }
    
    deinit {
        cancellables.removeAll()
        endBackgroundTask()
    }
    
    private func setupNotificationObservers() {
        // Listen for app lifecycle changes
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                self?.handleAppDidEnterBackground()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.handleAppWillEnterForeground()
            }
            .store(in: &cancellables)
    }
    
    private func handleAppDidEnterBackground() {
        backgroundEntryTime = Date()
        startBackgroundTask()
    }
    
    private func handleAppWillEnterForeground() {
        endBackgroundTask()
        updateTimerFromBackground()
    }
    
    private func startBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "FlowModeTimer") { [weak self] in
            // Background task is about to expire
            self?.endBackgroundTask()
        }
    }
    
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    private func updateTimerFromBackground() {
        guard let backgroundEntryTime = backgroundEntryTime,
              let timerService = timerService else { return }
        
        let backgroundDuration = Date().timeIntervalSince(backgroundEntryTime)
        
        // Update timer based on current state
        switch timerService.timerState {
        case .working:
            // Timer was running when app went to background, adjust for background time
            timerService.adjustForBackgroundTime(backgroundDuration)
            break
        case .breaking:
            // Break timer was running, adjust for background time to continue seamlessly
            timerService.adjustForBackgroundTime(backgroundDuration)
            break
        default:
            break
        }
        
        self.backgroundEntryTime = nil
    }
}
#endif