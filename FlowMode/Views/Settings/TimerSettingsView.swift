//
//  TimerSettingsView.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct TimerSettingsView: View {
    @EnvironmentObject var timerService: TimerService
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Timer Settings")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        PausePercentageRow(selectedPercentage: $timerService.settings.selectedPausePercentage)
                        
                        MaxWorkTimeRow(
                            isEnabled: $timerService.settings.maxWorkTimeEnabled,
                            minutes: $timerService.settings.maxWorkTimeMinutes
                        )
                        
                        Toggle("Stacked Time Display", isOn: $timerService.settings.useStackedTimeDisplay)
                        
                        Toggle("Show Timer Controls", isOn: $timerService.settings.showTimerControls)
                        
                        #if os(macOS)
                        DoubleTapSoundRow(selectedSound: $timerService.settings.doubleTapFeedbackSound)
                        #endif
                    }
                    .padding(.leading, 8)
                }
                
                Spacer()
            }
            .padding(24)
        }
        .navigationTitle("Timer")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
}