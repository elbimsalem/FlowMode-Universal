//
//  SubscriptionView.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct SubscriptionView: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    @EnvironmentObject var themeService: ThemeService
    @Environment(\.dismiss) private var dismiss
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.yellow)
                        
                        Text("FlowMode Premium")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Unlock the full potential of your productivity")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(icon: "infinity", title: "Unlimited Sessions", description: "No limits on work sessions")
                        FeatureRow(icon: "bell.badge", title: "Smart Notifications", description: "Advanced notification customization")
                        FeatureRow(icon: "speaker.wave.3", title: "Premium Sounds", description: "Access to all notification sounds")
                        FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Analytics", description: "Track your productivity over time")
                        FeatureRow(icon: "icloud", title: "Cloud Sync", description: "Sync your data across all devices")
                    }
                    .padding(.horizontal)
                    
                    // Current Status
                    if subscriptionService.subscriptionStatus.hasActiveAccess {
                        CurrentStatusView(status: subscriptionService.subscriptionStatus)
                    } else {
                        // Trial or Purchase Options
                        VStack(spacing: 16) {
                            if subscriptionService.canStartTrial {
                                TrialButton()
                            }
                            
                            PurchaseSection()
                        }
                    }
                    
                    // Restore Purchases
                    Button("Restore Purchases") {
                        Task {
                            await subscriptionService.restorePurchases()
                        }
                    }
                    .foregroundColor(.secondary)
                    .disabled(subscriptionService.isLoading)
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .scrollContentBackground(.hidden)
            .themedBackground(themeService.currentTheme)
            .navigationTitle("Premium")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(subscriptionService.errorMessage ?? "An error occurred")
            }
            .onChange(of: subscriptionService.errorMessage) { _, newValue in
                showingError = newValue != nil
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
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

struct CurrentStatusView: View {
    let status: SubscriptionStatus
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Premium Active")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            if status.state == .trial {
                Text("\(status.trialDaysRemaining) days remaining in trial")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else if let expirationDate = status.expirationDate {
                Text("Renews on \(expirationDate, style: .date)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
}

struct TrialButton: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    
    var body: some View {
        Button(action: {
            subscriptionService.startTrial()
        }) {
            VStack(spacing: 8) {
                Text("Start 7-Day Free Trial")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("Cancel anytime")
                    .font(.caption)
                    .opacity(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(subscriptionService.isLoading)
    }
}

struct PurchaseSection: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    
    var body: some View {
        VStack(spacing: 12) {
            if subscriptionService.availableProducts.isEmpty {
                ProgressView("Loading products...")
            } else {
                ForEach(subscriptionService.availableProducts, id: \.id) { product in
                    PurchaseButton(product: product)
                }
            }
        }
    }
}

struct PurchaseButton: View {
    let product: SubscriptionProduct
    @StateObject private var subscriptionService = SubscriptionService.shared
    
    var body: some View {
        Button(action: {
            Task {
                do {
                    try await subscriptionService.purchase(product: product)
                } catch {
                    // Error is handled by the service
                }
            }
        }) {
            HStack {
                VStack(alignment: .leading) {
                    Text(product.displayName)
                        .font(.headline)
                    Text("Monthly subscription")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(product.priceFormatted)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.accentColor, lineWidth: 2)
            )
            .cornerRadius(12)
        }
        .disabled(subscriptionService.isLoading)
        .opacity(subscriptionService.isLoading ? 0.6 : 1.0)
    }
}

#Preview {
    SubscriptionView()
}