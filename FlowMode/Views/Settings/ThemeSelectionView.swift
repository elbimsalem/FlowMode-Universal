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
            
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                ForEach(themeService.availableThemes) { theme in
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
            
            Spacer()
        }
        .padding(24)
        #else
        NavigationView {
            List(themeService.availableThemes) { theme in
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
            .scrollContentBackground(.hidden)
            .themedBackground(themeService.currentTheme)
        }
        #endif
    }
    
    private func handleThemeSelection(_ theme: Theme) {
        if themeService.canSelectTheme(theme, subscriptionStatus: subscriptionService.subscriptionStatus) {
            themeService.selectTheme(theme)
        } else {
            showingPaywall = true
        }
    }
}