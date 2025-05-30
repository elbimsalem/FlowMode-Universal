//
//  TimerControlsView.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct TimerControlsView: View {
    let timerState: TimerState
    let onPlayPause: () -> Void
    let onComplete: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        HStack(spacing: 40) {
            Button(action: onPlayPause) {
                Image(systemName: buttonImageName)
                    .font(.system(size: 60))
                    .foregroundColor(buttonColor)
            }
            .onLongPressGesture {
                onReset()
            }
            
            Button(action: onComplete) {
                Image(systemName: "stop.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(completeButtonColor)
            }
            .disabled(!completeButtonEnabled)
            
            Button(action: onReset) {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(resetButtonColor)
            }
            .disabled(!resetButtonEnabled)
        }
    }
    
    private var resetButtonEnabled: Bool {
        timerState != .idle
    }
    
    private var resetButtonColor: Color {
        resetButtonEnabled ? .gray : .gray.opacity(0.3)
    }
    
    private var completeButtonEnabled: Bool {
        switch timerState {
        case .working, .workPaused:
            return true
        default:
            return false
        }
    }
    
    private var completeButtonColor: Color {
        completeButtonEnabled ? .red : .gray
    }
    
    private var buttonImageName: String {
        switch timerState {
        case .idle:
            return "play.circle.fill"
        case .working:
            return "pause.circle.fill"
        case .workPaused:
            return "play.circle.fill"
        case .workCompleted:
            return "play.circle.fill"
        default:
            return "play.circle.fill"
        }
    }
    
    private var buttonColor: Color {
        switch timerState {
        case .idle:
            return .green
        case .working:
            return .orange
        case .workPaused:
            return .green
        case .workCompleted:
            return .green
        case .breaking:
            return .green
        default:
            return .green
        }
    }
}