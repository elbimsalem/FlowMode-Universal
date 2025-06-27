//
//  DebugSettingsView.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct DebugSettingsView: View {
    @EnvironmentObject var subscriptionService: SubscriptionService
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Debug Controls")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(themeService.currentTheme.primaryTextColor.color)
                    
                    Text("These controls are only available in debug builds and allow testing different subscription states.")
                        .foregroundColor(themeService.currentTheme.secondaryTextColor.color)
                        .font(.subheadline)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Subscription Debug Controls")
                                .font(.headline)
                            
                            Button("Reset Trial to 7 Days") {
                                let newStatus = SubscriptionStatus(
                                    state: .trial,
                                    trialStartDate: Date(),
                                    subscriptionStartDate: nil,
                                    expirationDate: nil
                                )
                                subscriptionService.subscriptionStatus = newStatus
                            }
                            .buttonStyle(.bordered)
                            
                            Button("End Trial") {
                                let pastDate = Calendar.current.date(byAdding: .day, value: -8, to: Date()) ?? Date()
                                let newStatus = SubscriptionStatus(
                                    state: .expired,
                                    trialStartDate: pastDate,
                                    subscriptionStartDate: nil,
                                    expirationDate: nil
                                )
                                subscriptionService.subscriptionStatus = newStatus
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Reset to Not Started") {
                                let newStatus = SubscriptionStatus(
                                    state: .notStarted,
                                    trialStartDate: nil,
                                    subscriptionStartDate: nil,
                                    expirationDate: nil
                                )
                                subscriptionService.subscriptionStatus = newStatus
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Simulate Active Subscription") {
                                let newStatus = SubscriptionStatus(
                                    state: .active,
                                    trialStartDate: nil,
                                    subscriptionStartDate: Date(),
                                    expirationDate: Calendar.current.date(byAdding: .year, value: 1, to: Date())
                                )
                                subscriptionService.subscriptionStatus = newStatus
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Subscription Status")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("State:")
                                    Spacer()
                                    Text(subscriptionService.subscriptionStatus.state.rawValue)
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    Text("Has Active Access:")
                                    Spacer()
                                    Text(subscriptionService.subscriptionStatus.hasActiveAccess ? "Yes" : "No")
                                        .foregroundColor(subscriptionService.subscriptionStatus.hasActiveAccess ? .green : .red)
                                }
                                
                                if let trialStartDate = subscriptionService.subscriptionStatus.trialStartDate {
                                    HStack {
                                        Text("Trial Started:")
                                        Spacer()
                                        Text(trialStartDate, style: .date)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                if let subscriptionStartDate = subscriptionService.subscriptionStatus.subscriptionStartDate {
                                    HStack {
                                        Text("Subscription Started:")
                                        Spacer()
                                        Text(subscriptionStartDate, style: .date)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .font(.subheadline)
                        }
                    }
                    .padding(.leading, 8)
                }
                
                Spacer()
            }
            .padding(24)
        }
        .scrollContentBackground(.hidden)
        .themedBackground(themeService.currentTheme)
        .navigationTitle("Debug")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
}