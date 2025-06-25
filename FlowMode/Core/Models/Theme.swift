//
//  Theme.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct Theme: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let isPremium: Bool
    
    // Timer ring colors
    let primaryRingColor: CodableColor
    let secondaryRingColor: CodableColor
    let ringBackgroundColor: CodableColor
    
    // Timer text colors
    let primaryTextColor: CodableColor
    let secondaryTextColor: CodableColor
    
    // Background
    let backgroundColor: CodableColor
    let useGradientBackground: Bool
    let gradientEndColor: CodableColor?
    
    // Visual effects
    let glowEffect: Bool
    let glowColor: CodableColor?
    let glowRadius: Double
}