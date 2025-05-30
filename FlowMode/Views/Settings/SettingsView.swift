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
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        #if os(macOS)
        NavigationStack {
            TabView {
                // General Tab
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Timer Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Timer")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                PausePercentageRow(selectedPercentage: $timerService.settings.selectedPausePercentage)
                                
                                MaxWorkTimeRow(
                                    isEnabled: $timerService.settings.maxWorkTimeEnabled,
                                    minutes: $timerService.settings.maxWorkTimeMinutes
                                )
                                
                                Toggle("Stacked Time Display", isOn: $timerService.settings.useStackedTimeDisplay)
                            }
                            .padding(.leading, 8)
                        }
                        
                        Divider()
                        
                        // Notifications & Sounds Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Notifications")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Toggle("Max Work Time Alert", isOn: $timerService.settings.notifyMaxWorkTime)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Picker("", selection: $timerService.settings.maxWorkTimeSound) {
                                        ForEach(SoundService.availableSounds, id: \.name) { sound in
                                            Text(sound.name).tag(Optional(sound.name))
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .frame(width: 150)
                                    .disabled(!timerService.settings.notifyMaxWorkTime)
                                    .opacity(timerService.settings.notifyMaxWorkTime ? 1.0 : 0.5)
                                    .onChange(of: timerService.settings.maxWorkTimeSound) { _, newValue in
                                        if let soundName = newValue, timerService.settings.notifyMaxWorkTime {
                                            SoundService.playSound(named: soundName)
                                        }
                                    }
                                }
                                
                                HStack {
                                    Toggle("Break Complete Alert", isOn: $timerService.settings.notifyPauseComplete)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Picker("", selection: $timerService.settings.pauseCompleteSound) {
                                        ForEach(SoundService.availableSounds, id: \.name) { sound in
                                            Text(sound.name).tag(Optional(sound.name))
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .frame(width: 150)
                                    .disabled(!timerService.settings.notifyPauseComplete)
                                    .opacity(timerService.settings.notifyPauseComplete ? 1.0 : 0.5)
                                    .onChange(of: timerService.settings.pauseCompleteSound) { _, newValue in
                                        if let soundName = newValue, timerService.settings.notifyPauseComplete {
                                            SoundService.playSound(named: soundName)
                                        }
                                    }
                                }
                            }
                            .padding(.leading, 8)
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(24)
                }
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("General")
                }
                
                // Premium Tab
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Premium")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(subscriptionService.subscriptionStatus.state.displayName)
                                        .font(.headline)
                                    
                                    if subscriptionService.subscriptionStatus.state == .trial {
                                        Text("\(subscriptionService.subscriptionStatus.trialDaysRemaining) days remaining")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } else if !subscriptionService.subscriptionStatus.hasActiveAccess {
                                        Text("Upgrade to unlock all features")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(subscriptionService.subscriptionStatus.hasActiveAccess ? "Manage" : "Start Trial") {
                                    if subscriptionService.subscriptionStatus.hasActiveAccess {
                                        // Open App Store subscription management
                                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                            #if os(macOS)
                                            NSWorkspace.shared.open(url)
                                            #else
                                            UIApplication.shared.open(url)
                                            #endif
                                        }
                                    } else {
                                        subscriptionService.startTrial()
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .padding(.leading, 8)
                        }
                        
                        Divider()
                        
                        // Premium Features List
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Premium Features")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                FeatureRow(icon: "infinity", title: "Unlimited Sessions", description: "No limits on work sessions")
                                FeatureRow(icon: "bell.badge", title: "Smart Notifications", description: "Advanced notification customization")
                                FeatureRow(icon: "speaker.wave.3", title: "Premium Sounds", description: "Access to all notification sounds")
                                FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Analytics", description: "Track your productivity over time")
                                FeatureRow(icon: "icloud", title: "Cloud Sync", description: "Sync your data across all devices")
                            }
                            .padding(.leading, 8)
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(24)
                }
                .tabItem {
                    Image(systemName: "crown")
                    Text("Premium")
                }
                
                // Debug Tab
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Debug")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Button("Reset Trial to 7 Days") {
                                    let newStatus = SubscriptionStatus(
                                        state: .trial,
                                        trialStartDate: Date(),
                                        subscriptionStartDate: nil,
                                        expirationDate: nil
                                    )
                                    subscriptionService.subscriptionStatus = newStatus
                                }
                                .buttonStyle(.borderedProminent)
                                
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
                            .padding(.leading, 8)
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(24)
                }
                .tabItem {
                    Image(systemName: "ladybug")
                    Text("Debug")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        #else
        NavigationStack {
            Form {
                Section("Premium") {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(subscriptionService.subscriptionStatus.state.displayName)
                                .font(.headline)
                            
                            if subscriptionService.subscriptionStatus.state == .trial {
                                Text("\(subscriptionService.subscriptionStatus.trialDaysRemaining) days remaining")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else if !subscriptionService.subscriptionStatus.hasActiveAccess {
                                Text("Upgrade to unlock all features")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if subscriptionService.subscriptionStatus.hasActiveAccess {
                            Button("Manage") {
                                if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        } else {
                            NavigationLink("Upgrade") {
                                SubscriptionView()
                                    .environmentObject(subscriptionService)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                    }
                }
                
                Section("Timer") {
                    PausePercentageRow(selectedPercentage: $timerService.settings.selectedPausePercentage)
                    
                    MaxWorkTimeRow(
                        isEnabled: $timerService.settings.maxWorkTimeEnabled,
                        minutes: $timerService.settings.maxWorkTimeMinutes
                    )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Toggle("Stacked Time Display", isOn: $timerService.settings.useStackedTimeDisplay)
                        Text("Show time as HH/MM/SS stacked vertically")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Notifications") {
                    HStack {
                        Toggle("Max Work Time Alert", isOn: $timerService.settings.notifyMaxWorkTime)
                        
                        NavigationLink {
                            SoundSelectionView(
                                selectedSound: $timerService.settings.maxWorkTimeSound,
                                title: "Max Work Time Sound"
                            )
                        } label: {
                            Text(timerService.settings.maxWorkTimeSound ?? "None")
                                .foregroundColor(timerService.settings.notifyMaxWorkTime ? .primary : .secondary)
                        }
                        .disabled(!timerService.settings.notifyMaxWorkTime)
                    }
                    
                    HStack {
                        Toggle("Break Complete Alert", isOn: $timerService.settings.notifyPauseComplete)
                        
                        NavigationLink {
                            SoundSelectionView(
                                selectedSound: $timerService.settings.pauseCompleteSound,
                                title: "Break Complete Sound"
                            )
                        } label: {
                            Text(timerService.settings.pauseCompleteSound ?? "None")
                                .foregroundColor(timerService.settings.notifyPauseComplete ? .primary : .secondary)
                        }
                        .disabled(!timerService.settings.notifyPauseComplete)
                    }
                }
                
                Section("Debug") {
                    Button("Reset Trial to 7 Days") {
                        let newStatus = SubscriptionStatus(
                            state: .trial,
                            trialStartDate: Date(),
                            subscriptionStartDate: nil,
                            expirationDate: nil
                        )
                        subscriptionService.subscriptionStatus = newStatus
                    }
                    .foregroundColor(.blue)
                    
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
                    .foregroundColor(.red)
                    
                    Button("Reset to Not Started") {
                        let newStatus = SubscriptionStatus(
                            state: .notStarted,
                            trialStartDate: nil,
                            subscriptionStartDate: nil,
                            expirationDate: nil
                        )
                        subscriptionService.subscriptionStatus = newStatus
                    }
                    .foregroundColor(.orange)
                }
            }
            .navigationTitle("Settings")
        }
        #endif
    }
}