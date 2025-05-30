//
//  TimerSettings.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import Foundation

struct TimerSettings: Codable {
    var selectedPausePercentage: Int = 10
    var selectedMaxWorkTime: Int = 0
    var maxWorkTimeEnabled: Bool = false
    var maxWorkTimeMinutes: Int = 25
    var maxWorkTimeSound: String? = "Notification"
    var pauseCompleteSound: String? = "Notification"
    var notifyMaxWorkTime: Bool = true
    var notifyPauseComplete: Bool = true
}