//
//  TimerDisplayView.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct TimerDisplayView: View {
    let seconds: Int
    let timerState: TimerState
    
    var body: some View {
        Text(TimeFormatter.formatSeconds(seconds))
            .font(.system(size: 60, weight: .light, design: .monospaced))
            .foregroundColor(displayColor)
    }
    
    private var displayColor: Color {
        switch timerState {
        case .workCompleted, .breaking, .breakPaused:
            return .green
        default:
            return .primary
        }
    }
}