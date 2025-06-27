//
//  View+Extensions.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func themedBackground(_ theme: Theme) -> some View {
        ZStack {
            if theme.useGradientBackground,
               let gradientEnd = theme.gradientEndColor {
                LinearGradient(
                    colors: [
                        theme.backgroundColor.color,
                        gradientEnd.color
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            } else {
                theme.backgroundColor.color
                    .ignoresSafeArea()
            }
            
            self
        }
    }
}