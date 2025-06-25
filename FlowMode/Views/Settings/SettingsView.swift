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
        #if os(macOS)
        NavigationSplitView(columnVisibility: .constant(.all)) {
            // Sidebar
            List(selection: $selectedCategory) {
                Section("Settings") {
                    ForEach(SettingsCategory.allCases) { category in
                        NavigationLink(value: category) {
                            Label(category.rawValue, systemImage: category.icon)
                        }
                    }
                }
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
            // Sidebar
            List(selection: $selectedCategory) {
                Section("Settings") {
                    ForEach(SettingsCategory.allCases) { category in
                        NavigationLink(value: category) {
                            Label(category.rawValue, systemImage: category.icon)
                        }
                    }
                }
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
}