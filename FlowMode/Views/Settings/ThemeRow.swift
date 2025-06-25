//
//  ThemeRow.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct ThemeRow: View {
    let theme: Theme
    let isSelected: Bool
    let isLocked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                // Theme preview
                ThemePreview(theme: theme)
                    .frame(width: 60, height: 60)
                
                VStack(alignment: .leading) {
                    Text(theme.name)
                        .font(.headline)
                    
                    if theme.isPremium {
                        Label("Premium", systemImage: "crown.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                } else if isLocked {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLocked)
        .opacity(isLocked ? 0.6 : 1.0)
    }
}