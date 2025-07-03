//
//  SettingsCategory.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

enum SettingsCategory: String, CaseIterable, Identifiable {
    case timer = "Timer"
    case theme = "Theme"
    case notifications = "Notifications"
    case subscription = "Subscription"
    case about = "About"
    case testing = "Testing"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .timer:
            return "timer"
        case .theme:
            return "paintbrush.fill"
        case .notifications:
            return "bell"
        case .subscription:
            return "crown"
        case .about:
            return "info.circle"
        case .testing:
            return "ladybug"
        }
    }
    
    var description: String {
        switch self {
        case .timer:
            return "Timer settings and preferences"
        case .theme:
            return "Customize timer appearance"
        case .notifications:
            return "Notification and sound settings"
        case .subscription:
            return "Premium features and subscription"
        case .about:
            return "App information and support"
        case .testing:
            return "Testing and development controls"
        }
    }
}