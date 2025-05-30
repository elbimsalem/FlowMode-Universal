//
//  SettingsView.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var timerService: TimerService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        #if os(macOS)
        NavigationStack {
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
                Section("Timer") {
                    PausePercentageRow(selectedPercentage: $timerService.settings.selectedPausePercentage)
                    
                    MaxWorkTimeRow(
                        isEnabled: $timerService.settings.maxWorkTimeEnabled,
                        minutes: $timerService.settings.maxWorkTimeMinutes
                    )
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
            }
            .navigationTitle("Settings")
        }
        #endif
    }
}