//
//  NotificationSettingsView.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @EnvironmentObject var timerService: TimerService
    @EnvironmentObject var themeService: ThemeService
    @State private var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Notification Settings")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(themeService.currentTheme.primaryTextColor.color)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        if authorizationStatus == .denied {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notifications Disabled")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                
                                Text("Please enable notifications in System Settings to receive timer alerts.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        #if os(macOS)
                        HStack {
                            Toggle("Max Work Time Alert", isOn: $timerService.settings.notifyMaxWorkTime)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .disabled(authorizationStatus == .denied)
                            
                            Picker("", selection: $timerService.settings.maxWorkTimeSound) {
                                ForEach(SoundService.availableSounds, id: \.name) { sound in
                                    Text(sound.name).tag(Optional(sound.name))
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 150)
                            .disabled(!timerService.settings.notifyMaxWorkTime || authorizationStatus == .denied)
                            .opacity(timerService.settings.notifyMaxWorkTime && authorizationStatus != .denied ? 1.0 : 0.5)
                            .onChange(of: timerService.settings.maxWorkTimeSound) { _, newValue in
                                if let soundName = newValue, timerService.settings.notifyMaxWorkTime {
                                    SoundService.playSound(named: soundName)
                                }
                            }
                        }
                        
                        HStack {
                            Toggle("Break Complete Alert", isOn: $timerService.settings.notifyPauseComplete)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .disabled(authorizationStatus == .denied)
                            
                            Picker("", selection: $timerService.settings.pauseCompleteSound) {
                                ForEach(SoundService.availableSounds, id: \.name) { sound in
                                    Text(sound.name).tag(Optional(sound.name))
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 150)
                            .disabled(!timerService.settings.notifyPauseComplete || authorizationStatus == .denied)
                            .opacity(timerService.settings.notifyPauseComplete && authorizationStatus != .denied ? 1.0 : 0.5)
                            .onChange(of: timerService.settings.pauseCompleteSound) { _, newValue in
                                if let soundName = newValue, timerService.settings.notifyPauseComplete {
                                    SoundService.playSound(named: soundName)
                                }
                            }
                        }
                        #else
                        HStack {
                            Toggle("Max Work Time Alert", isOn: $timerService.settings.notifyMaxWorkTime)
                                .disabled(authorizationStatus == .denied)
                            
                            NavigationLink {
                                SoundSelectionView(
                                    selectedSound: $timerService.settings.maxWorkTimeSound,
                                    title: "Max Work Time Sound"
                                )
                            } label: {
                                Text(timerService.settings.maxWorkTimeSound ?? "None")
                                    .foregroundColor(timerService.settings.notifyMaxWorkTime && authorizationStatus != .denied ? .primary : .secondary)
                            }
                            .disabled(!timerService.settings.notifyMaxWorkTime || authorizationStatus == .denied)
                        }
                        
                        HStack {
                            Toggle("Break Complete Alert", isOn: $timerService.settings.notifyPauseComplete)
                                .disabled(authorizationStatus == .denied)
                            
                            NavigationLink {
                                SoundSelectionView(
                                    selectedSound: $timerService.settings.pauseCompleteSound,
                                    title: "Break Complete Sound"
                                )
                            } label: {
                                Text(timerService.settings.pauseCompleteSound ?? "None")
                                    .foregroundColor(timerService.settings.notifyPauseComplete && authorizationStatus != .denied ? .primary : .secondary)
                            }
                            .disabled(!timerService.settings.notifyPauseComplete || authorizationStatus == .denied)
                        }
                        #endif
                    }
                    .padding(.leading, 8)
                }
                
                Spacer()
            }
            .padding(24)
        }
        .scrollContentBackground(.hidden)
        .themedBackground(themeService.currentTheme)
        .navigationTitle("Notifications")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .onAppear {
            checkAuthorizationStatus()
        }
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                authorizationStatus = settings.authorizationStatus
            }
        }
    }
}