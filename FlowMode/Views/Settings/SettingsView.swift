//
//  SettingsView.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var timerService: TimerService
    @EnvironmentObject var subscriptionService: SubscriptionService
    @EnvironmentObject var themeService: ThemeService
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: SettingsCategory? = .timer
    
    var body: some View {
        Group {
            #if os(macOS)
            NavigationSplitView(columnVisibility: .constant(.all)) {
            // Sidebar with theme background
            ZStack {
                // Theme background for sidebar
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
                
                List(selection: $selectedCategory) {
                    ForEach(SettingsCategory.allCases) { category in
                        NavigationLink(value: category) {
                            Label(category.rawValue, systemImage: category.icon)
                                .foregroundColor(themeService.currentTheme.primaryTextColor.color)
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .navigationTitle("Settings")
            .navigationSplitViewColumnWidth(min: 200, ideal: 250)
            .toolbar(removing: .sidebarToggle)
        } detail: {
            // Detail view
            Group {
                if let selectedCategory = selectedCategory {
                    switch selectedCategory {
                    case .timer:
                        TimerSettingsView()
                    case .theme:
                        ThemeSelectionView()
                    case .notifications:
                        NotificationSettingsView()
                    case .subscription:
                        SubscriptionView()
                    case .about:
                        AboutSettingsView()
                    #if DEBUG
                    case .debug:
                        DebugSettingsView()
                    #endif
                    }
                } else {
                    ContentUnavailableView(
                        "Select a Setting",
                        systemImage: "gearshape",
                        description: Text("Choose a setting category from the sidebar")
                    )
                }
            }
            .navigationSplitViewColumnWidth(min: 400, ideal: 600)
        }
        #else
        NavigationSplitView {
            // Sidebar with theme background
            ZStack {
                // Theme background for sidebar
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
                
                List(selection: $selectedCategory) {
                    ForEach(SettingsCategory.allCases) { category in
                        NavigationLink(value: category) {
                            Label(category.rawValue, systemImage: category.icon)
                                .foregroundColor(themeService.currentTheme.primaryTextColor.color)
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .navigationTitle("Settings")
        } detail: {
            // Detail view
            Group {
                if let selectedCategory = selectedCategory {
                    switch selectedCategory {
                    case .timer:
                        TimerSettingsView()
                    case .theme:
                        ThemeSelectionView()
                    case .notifications:
                        NotificationSettingsView()
                    case .subscription:
                        SubscriptionView()
                    case .about:
                        AboutSettingsView()
                    #if DEBUG
                    case .debug:
                        DebugSettingsView()
                    #endif
                    }
                } else {
                    ContentUnavailableView(
                        "Select a Setting",
                        systemImage: "gearshape",
                        description: Text("Choose a setting category from the sidebar")
                    )
                }
            }
        }
        #endif
        }
        .themedBackground(themeService.currentTheme)
        .animation(.easeInOut(duration: 0.3), value: themeService.currentTheme.id)
    }
}