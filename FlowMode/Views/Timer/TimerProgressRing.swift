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
    
    private let strokeWidth: CGFloat = 8
    private let ringSize: CGFloat = 200
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: strokeWidth)
                .frame(width: ringSize, height: ringSize)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(ringColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)
        }
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