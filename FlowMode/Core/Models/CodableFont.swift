
//
//  CodableFont.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct CodableFont: Codable, Equatable {
    let name: String?
    let size: Double
    let weight: String // e.g., "regular", "bold", "light"

    var font: Font {
        let resolvedWeight: Font.Weight
        switch weight.lowercased() {
        case "ultralight": resolvedWeight = .ultraLight
        case "thin": resolvedWeight = .thin
        case "light": resolvedWeight = .light
        case "regular": resolvedWeight = .regular
        case "medium": resolvedWeight = .medium
        case "semibold": resolvedWeight = .semibold
        case "bold": resolvedWeight = .bold
        case "heavy": resolvedWeight = .heavy
        case "black": resolvedWeight = .black
        default: resolvedWeight = .regular
        }

        if let name = name {
            return Font.custom(name, size: size).weight(resolvedWeight)
        } else {
            return Font.system(size: size, weight: resolvedWeight)
        }
    }
}
