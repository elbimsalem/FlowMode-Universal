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
            primaryRingColor: CodableColor(color: Color(hex: "007AFF")), // Blue
            secondaryRingColor: CodableColor(color: Color(hex: "FF9500")), // Orange
            ringBackgroundColor: CodableColor(color: Color(hex: "E5E5EA")), // Light Gray
            primaryTextColor: CodableColor(color: Color(hex: "000000")), // Black
            secondaryTextColor: CodableColor(color: Color(hex: "8E8E93")), // Gray
            backgroundColor: CodableColor(color: Color(hex: "F2F2F7")), // Light Background
            useGradientBackground: false,
            gradientEndColor: nil,
            glowEffect: false,
            glowColor: nil,
            glowRadius: 0,
            ringGlowEnabled: false,
            ringGlowRadius: 0,
            strokeWidth: 8,
            ringSpacing: 20,
            textGlowEnabled: false,
            textGlowRadius: 0,
            timerFont: CodableFont(name: nil, size: 80, weight: "regular")
        ),
        Theme(
            id: "minimal",
            name: "Minimal",
            isPremium: false,
            primaryRingColor: CodableColor(color: Color(hex: "000000")), // Black
            secondaryRingColor: CodableColor(color: Color(hex: "333333")), // Dark Gray
            ringBackgroundColor: CodableColor(color: Color(hex: "F0F0F0")), // Light Gray
            primaryTextColor: CodableColor(color: Color(hex: "000000")), // Black
            secondaryTextColor: CodableColor(color: Color(hex: "666666")), // Gray
            backgroundColor: CodableColor(color: Color(hex: "FFFFFF")), // White
            useGradientBackground: false,
            gradientEndColor: nil,
            glowEffect: false,
            glowColor: nil,
            glowRadius: 0,
            ringGlowEnabled: false,
            ringGlowRadius: 0,
            strokeWidth: 4,
            ringSpacing: 12,
            textGlowEnabled: false,
            textGlowRadius: 0,
            timerFont: CodableFont(name: nil, size: 70, weight: "light")
        ),
        Theme(
            id: "midnight",
            name: "Midnight",
            isPremium: true,
            primaryRingColor: CodableColor(color: Color(hex: "4A90E2")),
            secondaryRingColor: CodableColor(color: Color(hex: "7B68EE")),
            ringBackgroundColor: CodableColor(color: Color(hex: "1A1A2E")),
            primaryTextColor: CodableColor(color: Color(hex: "FFFFFF")),
            secondaryTextColor: CodableColor(color: Color(hex: "B8B8D0")),
            backgroundColor: CodableColor(color: Color(hex: "0F0F1E")),
            useGradientBackground: true,
            gradientEndColor: CodableColor(color: Color(hex: "1A1A2E")),
            glowEffect: false,
            glowColor: CodableColor(color: Color(hex: "4A90E2")),
            glowRadius: 10,
            ringGlowEnabled: true,
            ringGlowRadius: 4,
            strokeWidth: 8,
            ringSpacing: 20,
            textGlowEnabled: true,
            textGlowRadius: 3,
            timerFont: CodableFont(name: nil, size: 85, weight: "bold")
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
            glowRadius: 0,
            ringGlowEnabled: false,
            ringGlowRadius: 0,
            strokeWidth: 6,
            ringSpacing: 18,
            textGlowEnabled: false,
            textGlowRadius: 0,
            timerFont: CodableFont(name: nil, size: 75, weight: "semibold")
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
            glowEffect: false,
            glowColor: CodableColor(color: Color(hex: "FF6B6B")),
            glowRadius: 8,
            ringGlowEnabled: true,
            ringGlowRadius: 6,
            strokeWidth: 10,
            ringSpacing: 24,
            textGlowEnabled: true,
            textGlowRadius: 2,
            timerFont: CodableFont(name: nil, size: 90, weight: "heavy")
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
            glowEffect: false,
            glowColor: CodableColor(color: Color(hex: "00BCD4")),
            glowRadius: 12,
            ringGlowEnabled: true,
            ringGlowRadius: 5,
            strokeWidth: 9,
            ringSpacing: 22,
            textGlowEnabled: true,
            textGlowRadius: 4,
            timerFont: CodableFont(name: nil, size: 80, weight: "medium")
        ),
                // New themes
        Theme(
            id: "vibrant_sunset",
            name: "Vibrant Sunset",
            isPremium: true,
            primaryRingColor: CodableColor(color: Color(hex: "FF7E5F")), // Orange-red
            secondaryRingColor: CodableColor(color: Color(hex: "FEB47B")), // Lighter orange
            ringBackgroundColor: CodableColor(color: Color(hex: "3A2A2A")), // Dark brown-red
            primaryTextColor: CodableColor(color: .white),
            secondaryTextColor: CodableColor(color: Color(hex: "FFDAB9")), // Peach
            backgroundColor: CodableColor(color: Color(hex: "2A1A1A")), // Very dark brown-red
            useGradientBackground: true,
            gradientEndColor: CodableColor(color: Color(hex: "3A2A2A")),
            glowEffect: true,
            glowColor: CodableColor(color: Color(hex: "FF7E5F")),
            glowRadius: 6,
            ringGlowEnabled: true,
            ringGlowRadius: 3,
            strokeWidth: 8,
            ringSpacing: 20,
            textGlowEnabled: true,
            textGlowRadius: 2,
            timerFont: CodableFont(name: nil, size: 85, weight: "medium")
        ),
        Theme(
            id: "deep_ocean",
            name: "Deep Ocean",
            isPremium: true,
            primaryRingColor: CodableColor(color: Color(hex: "007BFF")), // Bright blue
            secondaryRingColor: CodableColor(color: Color(hex: "00CFFF")), // Cyan
            ringBackgroundColor: CodableColor(color: Color(hex: "001F3F")), // Very dark blue
            primaryTextColor: CodableColor(color: .white),
            secondaryTextColor: CodableColor(color: Color(hex: "ADD8E6")), // Light blue
            backgroundColor: CodableColor(color: Color(hex: "000A1A")), // Deepest blue
            useGradientBackground: true,
            gradientEndColor: CodableColor(color: Color(hex: "001F3F")),
            glowEffect: true,
            glowColor: CodableColor(color: Color(hex: "007BFF")),
            glowRadius: 10,
            ringGlowEnabled: true,
            ringGlowRadius: 5,
            strokeWidth: 10,
            ringSpacing: 25,
            textGlowEnabled: true,
            textGlowRadius: 4,
            timerFont: CodableFont(name: nil, size: 90, weight: "bold")
        ),
        Theme(
            id: "forest_retreat",
            name: "Forest Retreat",
            isPremium: true,
            primaryRingColor: CodableColor(color: Color(hex: "228B22")), // Forest green
            secondaryRingColor: CodableColor(color: Color(hex: "3CB371")), // Medium sea green
            ringBackgroundColor: CodableColor(color: Color(hex: "2F4F4F")), // Dark slate gray
            primaryTextColor: CodableColor(color: .white),
            secondaryTextColor: CodableColor(color: Color(hex: "90EE90")), // Light green
            backgroundColor: CodableColor(color: Color(hex: "1A2B2B")), // Dark teal
            useGradientBackground: false,
            gradientEndColor: nil,
            glowEffect: false,
            glowColor: nil,
            glowRadius: 0,
            ringGlowEnabled: false,
            ringGlowRadius: 0,
            strokeWidth: 6,
            ringSpacing: 18,
            textGlowEnabled: false,
            textGlowRadius: 0,
            timerFont: CodableFont(name: nil, size: 75, weight: "regular")
        ),
        Theme(
            id: "cyberpunk_neon",
            name: "Cyberpunk Neon",
            isPremium: true,
            primaryRingColor: CodableColor(color: Color(hex: "00FFFF")), // Aqua
            secondaryRingColor: CodableColor(color: Color(hex: "FF00FF")), // Magenta
            ringBackgroundColor: CodableColor(color: Color(hex: "1A0A1A")), // Very dark purple
            primaryTextColor: CodableColor(color: .white),
            secondaryTextColor: CodableColor(color: Color(hex: "00FF00")), // Lime green
            backgroundColor: CodableColor(color: Color(hex: "0A000A")), // Black-purple
            useGradientBackground: true,
            gradientEndColor: CodableColor(color: Color(hex: "1A0A1A")),
            glowEffect: true,
            glowColor: CodableColor(color: Color(hex: "00FFFF")),
            glowRadius: 15,
            ringGlowEnabled: true,
            ringGlowRadius: 7,
            strokeWidth: 12,
            ringSpacing: 28,
            textGlowEnabled: true,
            textGlowRadius: 6,
            timerFont: CodableFont(name: "Menlo", size: 95, weight: "bold") // Monospaced font for cyberpunk feel
        ),
        Theme(
            id: "minimalist_grey",
            name: "Minimalist Grey",
            isPremium: false,
            primaryRingColor: CodableColor(color: Color(hex: "808080")), // Grey
            secondaryRingColor: CodableColor(color: Color(hex: "A9A9A9")), // Dark grey
            ringBackgroundColor: CodableColor(color: Color(hex: "D3D3D3")), // Light grey
            primaryTextColor: CodableColor(color: .black),
            secondaryTextColor: CodableColor(color: Color(hex: "696969")), // Dim grey
            backgroundColor: CodableColor(color: .white),
            useGradientBackground: false,
            gradientEndColor: nil,
            glowEffect: false,
            glowColor: nil,
            glowRadius: 0,
            ringGlowEnabled: false,
            ringGlowRadius: 0,
            strokeWidth: 5,
            ringSpacing: 15,
            textGlowEnabled: false,
            textGlowRadius: 0,
            timerFont: CodableFont(name: nil, size: 70, weight: "light")
        ),
        Theme(
            id: "golden_hour",
            name: "Golden Hour",
            isPremium: true,
            primaryRingColor: CodableColor(color: Color(hex: "FFD700")), // Gold
            secondaryRingColor: CodableColor(color: Color(hex: "FFA500")), // Orange
            ringBackgroundColor: CodableColor(color: Color(hex: "4A3A00")), // Dark gold
            primaryTextColor: CodableColor(color: .white),
            secondaryTextColor: CodableColor(color: Color(hex: "FFEFD5")), // Papaya whip
            backgroundColor: CodableColor(color: Color(hex: "2A1A00")), // Very dark gold
            useGradientBackground: true,
            gradientEndColor: CodableColor(color: Color(hex: "4A3A00")),
            glowEffect: true,
            glowColor: CodableColor(color: Color(hex: "FFD700")),
            glowRadius: 8,
            ringGlowEnabled: true,
            ringGlowRadius: 4,
            strokeWidth: 9,
            ringSpacing: 22,
            textGlowEnabled: true,
            textGlowRadius: 3,
            timerFont: CodableFont(name: "Georgia", size: 88, weight: "semibold") // Elegant font
        ),
        Theme(
            id: "amethyst_dream",
            name: "Amethyst Dream",
            isPremium: true,
            primaryRingColor: CodableColor(color: Color(hex: "9966CC")), // Amethyst
            secondaryRingColor: CodableColor(color: Color(hex: "B19CD9")), // Light amethyst
            ringBackgroundColor: CodableColor(color: Color(hex: "330066")), // Dark purple
            primaryTextColor: CodableColor(color: .white),
            secondaryTextColor: CodableColor(color: Color(hex: "E6E6FA")), // Lavender
            backgroundColor: CodableColor(color: Color(hex: "1A0033")), // Very dark purple
            useGradientBackground: true,
            gradientEndColor: CodableColor(color: Color(hex: "330066")),
            glowEffect: true,
            glowColor: CodableColor(color: Color(hex: "9966CC")),
            glowRadius: 12,
            ringGlowEnabled: true,
            ringGlowRadius: 6,
            strokeWidth: 10,
            ringSpacing: 24,
            textGlowEnabled: true,
            textGlowRadius: 5,
            timerFont: CodableFont(name: "SnellRoundhand", size: 92, weight: "regular") // Whimsical font
        ),
        Theme(
            id: "volcanic_ash",
            name: "Volcanic Ash",
            isPremium: true,
            primaryRingColor: CodableColor(color: Color(hex: "FF4500")), // Orange-red
            secondaryRingColor: CodableColor(color: Color(hex: "B22222")), // Firebrick
            ringBackgroundColor: CodableColor(color: Color(hex: "2F4F4F")), // Dark slate gray
            primaryTextColor: CodableColor(color: .white),
            secondaryTextColor: CodableColor(color: Color(hex: "D3D3D3")), // Light grey
            backgroundColor: CodableColor(color: Color(hex: "1A1A1A")), // Very dark grey
            useGradientBackground: true,
            gradientEndColor: CodableColor(color: Color(hex: "2F4F4F")),
            glowEffect: true,
            glowColor: CodableColor(color: Color(hex: "FF4500")),
            glowRadius: 7,
            ringGlowEnabled: true,
            ringGlowRadius: 3.5,
            strokeWidth: 7,
            ringSpacing: 19,
            textGlowEnabled: true,
            textGlowRadius: 2.5,
            timerFont: CodableFont(name: nil, size: 80, weight: "heavy")
        ),
        Theme(
            id: "arctic_chill",
            name: "Arctic Chill",
            isPremium: true,
            primaryRingColor: CodableColor(color: Color(hex: "87CEEB")), // Sky blue
            secondaryRingColor: CodableColor(color: Color(hex: "ADD8E6")), // Light blue
            ringBackgroundColor: CodableColor(color: Color(hex: "E0FFFF")), // Light cyan
            primaryTextColor: CodableColor(color: .black),
            secondaryTextColor: CodableColor(color: Color(hex: "6A5ACD")), // Slate blue
            backgroundColor: CodableColor(color: .white),
            useGradientBackground: false,
            gradientEndColor: nil,
            glowEffect: false,
            glowColor: nil,
            glowRadius: 0,
            ringGlowEnabled: false,
            ringGlowRadius: 0,
            strokeWidth: 4,
            ringSpacing: 12,
            textGlowEnabled: false,
            textGlowRadius: 0,
            timerFont: CodableFont(name: nil, size: 70, weight: "thin")
        ),
        Theme(
            id: "retro_wave",
            name: "Retro Wave",
            isPremium: true,
            primaryRingColor: CodableColor(color: Color(hex: "FF1493")), // Deep pink
            secondaryRingColor: CodableColor(color: Color(hex: "00BFFF")), // Deep sky blue
            ringBackgroundColor: CodableColor(color: Color(hex: "4B0082")), // Indigo
            primaryTextColor: CodableColor(color: .white),
            secondaryTextColor: CodableColor(color: Color(hex: "FFD700")), // Gold
            backgroundColor: CodableColor(color: Color(hex: "191970")), // Midnight blue
            useGradientBackground: true,
            gradientEndColor: CodableColor(color: Color(hex: "4B0082")),
            glowEffect: true,
            glowColor: CodableColor(color: Color(hex: "FF1493")),
            glowRadius: 10,
            ringGlowEnabled: true,
            ringGlowRadius: 5,
            strokeWidth: 10,
            ringSpacing: 25,
            textGlowEnabled: true,
            textGlowRadius: 4,
            timerFont: CodableFont(name: "AvenirNextCondensed-Heavy", size: 90, weight: "heavy") // Bold, condensed font for retro feel
        )
    ]

    static func theme(withId id: String) -> Theme {
        defaultThemes.first { $0.id == id } ?? defaultThemes[0]
    }

    private static var systemBackground: Color {
        #if os(iOS)
        return Color(.systemBackground)
        #else
        return Color(.windowBackgroundColor)
        #endif
    }
}