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
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Theme preview
                ThemePreview(theme: theme)
                    .frame(width: 60, height: 60)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.name)
                        .font(.headline)
                    
                    if theme.isPremium {
                        Label("Premium", systemImage: "crown.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
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
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
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
}