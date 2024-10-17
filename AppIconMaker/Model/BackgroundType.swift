//
//  BackgroundType.swift
//  AppIconMaker
//
//  Created by Josafat Vicente Pérez on 17/10/24.
//

import SwiftUI

#if os(macOS)
import AppKit
typealias UIColor = NSColor
typealias UIFont = NSFont
typealias UIImage = NSImage
#endif

enum BackgroundType: String, CaseIterable, Identifiable {
    case solidColor = "Color Plano"
    case gradient = "Gradiente"

    var id: String { self.rawValue }
}

struct EmojiImageOptions {
    var emoji: String = "😊"
    var emojiSize: CGFloat = 512
    var backgroundType: BackgroundType = .solidColor
    var solidColor: Color = .white
    var gradientColors: [Color] = [.blue, .purple]
    var gradientColorCount: Int = 2
}
