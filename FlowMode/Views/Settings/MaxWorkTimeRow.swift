//
//  MaxWorkTimeRow.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct MaxWorkTimeRow: View {
    @Binding var isEnabled: Bool
    @Binding var minutes: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Max Work Time", isOn: $isEnabled)
            
            if isEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Duration: \(minutes) minutes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Slider(value: Binding(
                        get: { Double(minutes) },
                        set: { minutes = Int($0) }
                    ), in: 5...240, step: 5)
                    #if os(macOS)
                    .frame(maxWidth: .infinity)
                    #endif
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}