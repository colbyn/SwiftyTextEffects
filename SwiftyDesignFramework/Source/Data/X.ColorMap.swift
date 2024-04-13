//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 3/2/24.
//

import Foundation
import enum SwiftUI.ColorScheme

extension X {
    public struct ColorMap {
        public let light: X.Color
        public let dark: X.Color
        public init(light: X.Color, dark: X.Color) {
            self.light = light
            self.dark = dark
        }
        public init(light: () -> X.Color, dark: () -> X.Color) {
            self.light = light()
            self.dark = dark()
        }
        public init(singleton color: X.Color) {
            self.light = color
            self.dark = color
        }
    }
}

extension X.ColorMap {
    public func apply(colorScheme: ColorScheme) -> X.Color {
        switch colorScheme {
        case .light: return self.light
        case .dark: return self.dark
        default: return self.light
        }
    }
    public func callAsFunction(colorScheme: ColorScheme) -> X.Color {
        self.apply(colorScheme: colorScheme)
    }
    public func with(light: X.Color) -> Self {
        Self(light: light, dark: dark)
    }
    public func with(dark: X.Color) -> Self {
        Self(light: light, dark: dark)
    }
}

extension X.ColorMap {
    public static let `default`: Self = Self(light: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), dark: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    public static let red: Self = Self(light: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1), dark: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1))
    public static let green: Self = Self(light: #colorLiteral(red: 0.2778122788, green: 0.6918070885, blue: 0, alpha: 1), dark: #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1))
    public static let clear: Self = Self(light: X.Color.clear, dark: X.Color.clear)
    public static let unnoticeable: Self = Self(light: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.01), dark: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.01235708773))
}

#if os(iOS)
import UIKit
extension X.ColorMap {
    public var adaptiveColor: X.Color {
        X.Color { (traitCollection: UITraitCollection) -> X.Color in
            switch traitCollection.userInterfaceStyle {
            case .dark: return self.dark
            default: return self.light
            }
        }
    }
}
#endif


