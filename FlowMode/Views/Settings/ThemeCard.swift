//
//  ThemeCard.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct ThemeCard: View {
    let theme: Theme
    let isSelected: Bool
    let isLocked: Bool
    let currentTheme: Theme
    let action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Theme preview
                ThemePreview(theme: theme)
                    .frame(width: 60, height: 60)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.name)
                        .font(.headline)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(currentTheme.primaryRingColor.color)
                        .font(.title2)
                } else if isLocked {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.secondary)
                        .font(.title2)
                } else {
                    Circle()
                        .stroke(Color.secondary, lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColorForPlatform)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isLocked ? 0.8 : 1.0)
    }
    
    private var backgroundColorForPlatform: Color {
        #if os(macOS)
        return Color(.controlBackgroundColor)
        #else
        return Color(.secondarySystemGroupedBackground)
        #endif
    }
    
    private var borderColor: Color {
        if isSelected {
            // Selected themes use their primary ring color
            return currentTheme.primaryRingColor.color
        } else if colorScheme == .light {
            // Light mode: subtle gray border for definition
            return Color.secondary.opacity(0.3)
        } else {
            // Dark mode: no border (invisible)
            return Color.clear
        }
    }
}