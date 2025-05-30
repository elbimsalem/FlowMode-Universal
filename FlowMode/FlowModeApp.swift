//
//  FlowModeApp.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

@main
struct FlowModeApp: App {
    @StateObject private var timerService = TimerService()
    #if os(iOS)
    @StateObject private var backgroundTaskService: BackgroundTaskService
    #endif
    
    init() {
        let timer = TimerService()
        _timerService = StateObject(wrappedValue: timer)
        #if os(iOS)
        _backgroundTaskService = StateObject(wrappedValue: BackgroundTaskService(timerService: timer))
        #endif
        
        // Initialize notification service to request permissions
        _ = NotificationService.shared
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(timerService)
                #if os(iOS)
                .environmentObject(backgroundTaskService)
                #endif
        }
    }
}
