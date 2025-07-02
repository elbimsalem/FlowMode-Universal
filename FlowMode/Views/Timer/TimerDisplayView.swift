//
//  TimerDisplayView.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct TimerDisplayView: View {
    @EnvironmentObject var themeService: ThemeService
    let seconds: Int
    let timerState: TimerState
    let useStackedDisplay: Bool
    
    var body: some View {
        Group {
            if useStackedDisplay {
                VStack(spacing: -5) {
                    Text(hoursString)
                        .font(.system(size: 48, weight: .light, design: .monospaced))
                        .foregroundColor(displayColor)
                    
                    Text(minutesString)
                        .font(.system(size: 48, weight: .light, design: .monospaced))
                        .foregroundColor(displayColor)
                    
                    Text(secondsString)
                        .font(.system(size: 48, weight: .light, design: .monospaced))
                        .foregroundColor(displayColor)
                }
            } else {
                Text(TimeFormatter.formatSeconds(seconds))
                    .font(.system(size: 42, weight: .light, design: .monospaced))
                    .foregroundColor(displayColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
        .if(themeService.currentTheme.textGlowEnabled) { view in
            view.shadow(
                color: displayColor.opacity(0.8),
                radius: CGFloat(themeService.currentTheme.textGlowRadius)
            )
        }
    }
    
    private var hoursString: String {
        let hours = seconds / 3600
        return String(format: "%02d", hours)
    }
    
    private var minutesString: String {
        let minutes = (seconds % 3600) / 60
        return String(format: "%02d", minutes)
    }
    
    private var secondsString: String {
        let remainingSeconds = seconds % 60
        return String(format: "%02d", remainingSeconds)
    }
    
    private var displayColor: Color {
        switch timerState {
        case .workCompleted, .breaking, .breakPaused:
            return themeService.currentTheme.secondaryTextColor.color
        default:
            return themeService.currentTheme.primaryTextColor.color
        }
    }
}