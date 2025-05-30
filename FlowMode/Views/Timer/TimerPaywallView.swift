//
//  TimerPaywallView.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct TimerPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionService = SubscriptionService.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "timer")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                    
                    Text("Premium Timer Features")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Your trial has ended. Upgrade to continue using FlowMode's powerful productivity features.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Features
                VStack(alignment: .leading, spacing: 12) {
                    PaywallFeatureRow(icon: "play.circle", title: "Unlimited Timer Sessions", description: "Use the timer as much as you need")
                    PaywallFeatureRow(icon: "pause.circle", title: "Smart Break Tracking", description: "Automatic break time calculation")
                    PaywallFeatureRow(icon: "bell", title: "Custom Notifications", description: "Personalized alerts and sounds")
                    PaywallFeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Progress Tracking", description: "Visual progress rings and analytics")
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    if subscriptionService.canStartTrial {
                        Button(action: {
                            subscriptionService.startTrial()
                            dismiss()
                        }) {
                            Text("Start 7-Day Free Trial")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    
                    #if os(iOS)
                    NavigationLink {
                        SubscriptionView()
                            .environmentObject(subscriptionService)
                    } label: {
                        Text("View All Plans")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    #else
                    Button("View All Plans") {
                        // For macOS, we'll use the simple approach
                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal)
                    #endif
                }
                .padding(.bottom)
            }
            .padding()
            .navigationTitle("Premium Required")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                #endif
            }
        }
    }
}

struct PaywallFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    TimerPaywallView()
}