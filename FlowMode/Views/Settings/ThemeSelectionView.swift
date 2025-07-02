//
//  ThemeSelectionView.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct ThemeSelectionView: View {
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var subscriptionService: SubscriptionService
    @Environment(\.dismiss) var dismiss
    @State private var showingPaywall = false
    
    var body: some View {
        mainContent
            .sheet(isPresented: $showingPaywall) {
                TimerPaywallView()
                    .environmentObject(subscriptionService)
            }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        #if os(macOS)
        VStack(alignment: .leading, spacing: 24) {
            Text("Select Theme")
                .font(.title2)
                .fontWeight(.semibold)
            
            // Free Theme Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Free")
                    .font(.headline)
                    .foregroundColor(themeService.currentTheme.primaryTextColor.color)
                
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                    ForEach(freeThemes) { theme in
                        ThemeCard(
                            theme: theme,
                            isSelected: theme.id == themeService.currentTheme.id,
                            isLocked: !themeService.canSelectTheme(theme, subscriptionStatus: subscriptionService.subscriptionStatus),
                            currentTheme: themeService.currentTheme
                        ) {
                            handleThemeSelection(theme)
                        }
                    }
                }
            }
            
            // Premium Themes Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Premium")
                    .font(.headline)
                    .foregroundColor(themeService.currentTheme.primaryTextColor.color)
                
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                    ForEach(premiumThemes) { theme in
                        ThemeCard(
                            theme: theme,
                            isSelected: theme.id == themeService.currentTheme.id,
                            isLocked: !themeService.canSelectTheme(theme, subscriptionStatus: subscriptionService.subscriptionStatus),
                            currentTheme: themeService.currentTheme
                        ) {
                            handleThemeSelection(theme)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(24)
        #else
        NavigationView {
            List {
                // Free Theme Section
                Section("Free") {
                    ForEach(freeThemes) { theme in
                        ThemeCard(
                            theme: theme,
                            isSelected: theme.id == themeService.currentTheme.id,
                            isLocked: !themeService.canSelectTheme(theme, subscriptionStatus: subscriptionService.subscriptionStatus),
                            currentTheme: themeService.currentTheme
                        ) {
                            handleThemeSelection(theme)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                }
                
                // Premium Themes Section
                Section("Premium") {
                    ForEach(premiumThemes) { theme in
                        ThemeCard(
                            theme: theme,
                            isSelected: theme.id == themeService.currentTheme.id,
                            isLocked: !themeService.canSelectTheme(theme, subscriptionStatus: subscriptionService.subscriptionStatus),
                            currentTheme: themeService.currentTheme
                        ) {
                            handleThemeSelection(theme)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .themedBackground(themeService.currentTheme)
        }
        #endif
    }
    
    private var freeThemes: [Theme] {
        themeService.availableThemes.filter { !$0.isPremium }
    }
    
    private var premiumThemes: [Theme] {
        themeService.availableThemes.filter { $0.isPremium }
    }
    
    private func handleThemeSelection(_ theme: Theme) {
        if themeService.canSelectTheme(theme, subscriptionStatus: subscriptionService.subscriptionStatus) {
            themeService.selectTheme(theme)
        } else {
            showingPaywall = true
        }
    }
}