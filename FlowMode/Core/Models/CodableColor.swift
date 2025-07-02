//
//  CodableColor.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct CodableColor: Codable, Equatable {
    enum ColorType: String, Codable {
        case semantic
        case custom
    }
    
    enum SemanticColor: String, Codable {
        case primary
        case secondary
        case systemBackground
        case primaryOpacity06 = "primary.opacity(0.6)"
        case primaryOpacity01 = "primary.opacity(0.1)"
        case secondaryOpacity02 = "secondary.opacity(0.2)"
        case secondaryOpacity03 = "secondary.opacity(0.3)"
    }
    
    let type: ColorType
    let semanticColor: SemanticColor?
    let red: Double?
    let green: Double?
    let blue: Double?
    let opacity: Double?
    
    init(color: Color) {
        // Try to detect semantic colors and preserve them
        self.type = .custom
        self.semanticColor = nil
        
        #if os(iOS)
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        #elseif os(macOS)
        let nsColor = NSColor(color).usingColorSpace(.sRGB) ?? NSColor.black
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        nsColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        #endif
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.opacity = Double(a)
    }
    
    // Special initializer for semantic colors
    init(semantic: SemanticColor) {
        self.type = .semantic
        self.semanticColor = semantic
        self.red = nil
        self.green = nil
        self.blue = nil
        self.opacity = nil
    }
    
    var color: Color {
        switch type {
        case .semantic:
            guard let semanticColor = semanticColor else { 
                return Color.primary 
            }
            switch semanticColor {
            case .primary:
                return .primary
            case .secondary:
                return .secondary
            case .systemBackground:
                #if os(iOS)
                return Color(.systemBackground)
                #else
                return Color(.windowBackgroundColor)
                #endif
            case .primaryOpacity06:
                return .primary.opacity(0.6)
            case .primaryOpacity01:
                return .primary.opacity(0.1)
            case .secondaryOpacity02:
                return .secondary.opacity(0.2)
            case .secondaryOpacity03:
                return .secondary.opacity(0.3)
            }
        case .custom:
            return Color(red: red ?? 0, green: green ?? 0, blue: blue ?? 0, opacity: opacity ?? 1)
        }
    }
}