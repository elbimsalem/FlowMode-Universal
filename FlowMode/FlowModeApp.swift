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
    @StateObject private var subscriptionService = SubscriptionService.shared
    #if os(iOS)
    @StateObject private var backgroundTaskService = BackgroundTaskService()
    #endif
    
    init() {
        // Initialize services
        _ = NotificationService.shared
        _ = SubscriptionService.shared
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(timerService)
                .environmentObject(subscriptionService)
                #if os(iOS)
                .environmentObject(backgroundTaskService)
                #endif
                .onAppear {
                    #if os(iOS)
                    backgroundTaskService.setTimerService(timerService)
                    #endif
                }
        }
        
        #if os(macOS)
        Settings {
            SettingsView()
                .environmentObject(timerService)
                .environmentObject(subscriptionService)
        }
        .windowResizability(.contentMinSize)
        #endif
    }
}
