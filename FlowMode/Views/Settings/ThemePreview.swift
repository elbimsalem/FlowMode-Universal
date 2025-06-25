//
//  ThemePreview.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct ThemePreview: View {
    let theme: Theme
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.backgroundColor.color)
            
            // Mini timer ring
            Circle()
                .stroke(theme.ringBackgroundColor.color, lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(theme.primaryRingColor.color, lineWidth: 4)
                .rotationEffect(.degrees(-90))
            
            Circle()
                .trim(from: 0, to: 0.3)
                .stroke(theme.secondaryRingColor.color, lineWidth: 4)
                .rotationEffect(.degrees(-90))
                .scaleEffect(1.1)
            
            // Timer text preview
            Text("25:00")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(theme.primaryTextColor.color)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
        }
        .if(theme.glowEffect) { view in
            view.shadow(
                color: theme.glowColor?.color ?? .clear,
                radius: theme.glowRadius / 3
            )
        }
    }
}