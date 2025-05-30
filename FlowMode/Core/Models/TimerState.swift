//
//  TimerState.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import Foundation

enum TimerState: CaseIterable {
    case idle
    case working
    case workPaused
    case workCompleted
    case breaking
    case breakPaused
}