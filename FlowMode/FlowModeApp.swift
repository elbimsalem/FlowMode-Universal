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
    @StateObject private var themeService: ThemeService
    #if os(iOS)
    @StateObject private var backgroundTaskService = BackgroundTaskService()
    #endif
    
    init() {
        // Initialize services
        _ = NotificationService.shared
        _ = SubscriptionService.shared
        
        let timer = TimerService()
        let subscription = SubscriptionService.shared
        _timerService = StateObject(wrappedValue: timer)
        _themeService = StateObject(wrappedValue: ThemeService(timerService: timer, subscriptionService: subscription))
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(timerService)
                .environmentObject(subscriptionService)
                .environmentObject(themeService)
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
                .environmentObject(themeService)
        }
        .windowResizability(.contentMinSize)
        #endif
    }
}
