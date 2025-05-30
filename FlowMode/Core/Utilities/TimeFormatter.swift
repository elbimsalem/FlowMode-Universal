//
//  TimeFormatter.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import Foundation

struct TimeFormatter {
    static func formatSeconds(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
    }
}