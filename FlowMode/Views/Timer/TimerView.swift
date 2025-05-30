//
//  TimerView.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var timerService: TimerService
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                ZStack {
                    TimerProgressRing(
                        progress: timerService.progressPercentage,
                        timerState: timerService.timerState
                    )
                    
                    TimerDisplayView(
                        seconds: displaySeconds,
                        timerState: timerService.timerState
                    )
                }
                
                HStack(spacing: 20) {
                    Text("Break: \(timerService.settings.selectedPausePercentage)%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if timerService.settings.maxWorkTimeEnabled {
                        Text("Max: \(timerService.settings.maxWorkTimeMinutes)m")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                #if os(iOS)
                if SoundService.isPlayingContinuousSound {
                    Button("Stop Alarm") {
                        SoundService.stopContinuousSound()
                    }
                    .foregroundColor(.red)
                    .font(.headline)
                }
                #endif
            }
            
            TimerControlsView(
                timerState: timerService.timerState,
                onPlayPause: handlePlayPause,
                onComplete: handleComplete,
                onReset: handleReset
            )
        }
    }
    
    private var displaySeconds: Int {
        switch timerService.timerState {
        case .workCompleted, .breaking, .breakPaused:
            return timerService.remainingPauseSeconds
        default:
            return timerService.elapsedSeconds
        }
    }
    
    private func handlePlayPause() {
        switch timerService.timerState {
        case .idle:
            timerService.startWorkTimer()
        case .working:
            timerService.pauseWorkTimer()
        case .workPaused:
            timerService.resumeWorkTimer()
        case .workCompleted:
            timerService.startBreakTimer()
        default:
            break
        }
    }
    
    private func handleComplete() {
        switch timerService.timerState {
        case .working, .workPaused:
            timerService.completeWorkTimer()
        default:
            break
        }
    }
    
    private func handleReset() {
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        #endif
        timerService.resetTimer()
    }
}