//
//  TimerProgressRing.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct TimerProgressRing: View {
    let progress: CGFloat
    let timerState: TimerState
    let pauseProgress: CGFloat
    
    private let strokeWidth: CGFloat = 8
    private let ringSize: CGFloat = 200
    private let outerRingSize: CGFloat = 220
    
    var body: some View {
        ZStack {
            // Outer pause time ring background
            if shouldShowPauseRing {
                Circle()
                    .stroke(Color.gray.opacity(0.1), lineWidth: strokeWidth)
                    .frame(width: outerRingSize, height: outerRingSize)
            }
            
            // Outer pause time ring
            if shouldShowPauseRing {
                Circle()
                    .trim(from: 0, to: pauseProgress)
                    .stroke(Color.green.opacity(0.6), style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                    .frame(width: outerRingSize, height: outerRingSize)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: pauseProgress)
            }
            
            // Inner work time ring background
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: strokeWidth)
                .frame(width: ringSize, height: ringSize)
            
            // Inner work time progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(ringColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)
        }
    }
    
    private var shouldShowPauseRing: Bool {
        return true // Always show the outer ring
    }
    
    private var ringColor: Color {
        switch timerState {
        case .working, .workPaused:
            return .blue
        case .workCompleted, .breaking, .breakPaused:
            return .green
        default:
            return .gray
        }
    }
}