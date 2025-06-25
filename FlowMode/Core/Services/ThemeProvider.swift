//
//  ThemeProvider.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct ThemeProvider {
    static let defaultThemes: [Theme] = [
        Theme(
            id: "default",
            name: "Classic",
            isPremium: false,
            primaryRingColor: CodableColor(color: .blue),
            secondaryRingColor: CodableColor(color: .orange),
            ringBackgroundColor: CodableColor(color: .secondary.opacity(0.3)),
            primaryTextColor: CodableColor(color: .primary),
            secondaryTextColor: CodableColor(color: .secondary),
            backgroundColor: CodableColor(color: Color(.systemBackground)),
            useGradientBackground: false,
            gradientEndColor: nil,
            glowEffect: false,
            glowColor: nil,
            glowRadius: 0
        ),
        Theme(
            id: "midnight",
            name: "Midnight",
            isPremium: true,
            primaryRingColor: CodableColor(color: Color(hex: "4A90E2")),
            secondaryRingColor: CodableColor(color: Color(hex: "7B68EE")),
            ringBackgroundColor: CodableColor(color: Color(hex: "1A1A2E")),
            primaryTextColor: CodableColor(color: .white),
            secondaryTextColor: CodableColor(color: Color(hex: "B8B8D0")),
            backgroundColor: CodableColor(color: Color(hex: "0F0F1E")),
            useGradientBackground: true,
            gradientEndColor: CodableColor(color: Color(hex: "1A1A2E")),
            glowEffect: true,
            glowColor: CodableColor(color: Color(hex: "4A90E2")),
            glowRadius: 10
        ),
        Theme(
            id: "forest",
            name: "Forest",
            isPremium: true,
            primaryRingColor: CodableColor(color: Color(hex: "27AE60")),
            secondaryRingColor: CodableColor(color: Color(hex: "229954")),
            ringBackgroundColor: CodableColor(color: Color(hex: "1E3A2A")),
            primaryTextColor: CodableColor(color: Color(hex: "E8F5E9")),
            secondaryTextColor: CodableColor(color: Color(hex: "A5D6A7")),
            backgroundColor: CodableColor(color: Color(hex: "0D2818")),
            useGradientBackground: true,
            gradientEndColor: CodableColor(color: Color(hex: "1A3A2A")),
            glowEffect: false,
            glowColor: nil,
            glowRadius: 0
        ),
        Theme(
            id: "sunset",
            name: "Sunset",
            isPremium: true,
            primaryRingColor: CodableColor(color: Color(hex: "FF6B6B")),
            secondaryRingColor: CodableColor(color: Color(hex: "FFE66D")),
            ringBackgroundColor: CodableColor(color: Color(hex: "4A3C3C")),
            primaryTextColor: CodableColor(color: Color(hex: "FFF5F5")),
            secondaryTextColor: CodableColor(color: Color(hex: "FFB5B5")),
            backgroundColor: CodableColor(color: Color(hex: "2D1B1B")),
            useGradientBackground: true,
            gradientEndColor: CodableColor(color: Color(hex: "4A2C2C")),
            glowEffect: true,
            glowColor: CodableColor(color: Color(hex: "FF6B6B")),
            glowRadius: 8
        ),
        Theme(
            id: "ocean",
            name: "Ocean",
            isPremium: true,
            primaryRingColor: CodableColor(color: Color(hex: "00BCD4")),
            secondaryRingColor: CodableColor(color: Color(hex: "00ACC1")),
            ringBackgroundColor: CodableColor(color: Color(hex: "1A3A4A")),
            primaryTextColor: CodableColor(color: Color(hex: "E0F7FA")),
            secondaryTextColor: CodableColor(color: Color(hex: "80DEEA")),
            backgroundColor: CodableColor(color: Color(hex: "0A1929")),
            useGradientBackground: true,
            gradientEndColor: CodableColor(color: Color(hex: "1A3A4A")),
            glowEffect: true,
            glowColor: CodableColor(color: Color(hex: "00BCD4")),
            glowRadius: 12
        )
    ]
    
    static func theme(withId id: String) -> Theme {
        defaultThemes.first { $0.id == id } ?? defaultThemes[0]
    }
}