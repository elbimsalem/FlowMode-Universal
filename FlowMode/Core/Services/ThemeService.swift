//
//  ThemeService.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI
import Combine

class ThemeService: ObservableObject {
    @Published var currentTheme: Theme
    @Published var availableThemes: [Theme] = ThemeProvider.defaultThemes
    
    private let timerService: TimerService
    private let subscriptionService: SubscriptionService
    private var cancellables = Set<AnyCancellable>()
    
    init(timerService: TimerService, subscriptionService: SubscriptionService) {
        self.timerService = timerService
        self.subscriptionService = subscriptionService
        
        // Validate theme exists and fallback to default if needed
        let selectedThemeId = timerService.settings.selectedThemeId
        let themes = ThemeProvider.defaultThemes
        if !themes.contains(where: { $0.id == selectedThemeId }) {
            timerService.settings.selectedThemeId = "default"
            self.currentTheme = ThemeProvider.theme(withId: "default")
        } else {
            self.currentTheme = ThemeProvider.theme(withId: selectedThemeId)
        }
        
        // Observe theme changes
        timerService.$settings
            .map { $0.selectedThemeId }
            .removeDuplicates()
            .sink { [weak self] themeId in
                self?.currentTheme = ThemeProvider.theme(withId: themeId)
            }
            .store(in: &cancellables)
        
        // Observe subscription status changes
        subscriptionService.$subscriptionStatus
            .map { $0.hasActiveAccess }
            .removeDuplicates()
            .sink { [weak self] hasActiveAccess in
                self?.handleSubscriptionStatusChange(hasActiveAccess: hasActiveAccess)
            }
            .store(in: &cancellables)
    }
    
    private func handleSubscriptionStatusChange(hasActiveAccess: Bool) {
        // If subscription expired and current theme is premium, switch to Classic
        if !hasActiveAccess && currentTheme.isPremium {
            selectTheme(ThemeProvider.theme(withId: "default"))
        }
    }
    
    func selectTheme(_ theme: Theme) {
        timerService.settings.selectedThemeId = theme.id
    }
    
    func canSelectTheme(_ theme: Theme, subscriptionStatus: SubscriptionStatus) -> Bool {
        return !theme.isPremium || subscriptionStatus.hasActiveAccess
    }
}