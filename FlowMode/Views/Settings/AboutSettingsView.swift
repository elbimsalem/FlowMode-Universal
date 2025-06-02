//
//  AboutSettingsView.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct AboutSettingsView: View {
    @EnvironmentObject var subscriptionService: SubscriptionService
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("About FlowMode")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("FlowMode is a productivity timer app that implements the Flowmodoro technique.")
                            .foregroundColor(.secondary)
                        
                        Divider()
                        
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Build")
                            Spacer()
                            Text("2")
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        #if DEBUG
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Debug Controls")
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
                        }
                        #endif
                    }
                    .padding(.leading, 8)
                }
                
                Spacer()
            }
            .padding(24)
        }
        .navigationTitle("About")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
}