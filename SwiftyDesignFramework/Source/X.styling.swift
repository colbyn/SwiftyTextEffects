//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 3/3/24.
//

import SwiftUI


// MARK: - PUBLIC API -
extension View {
    public func xForegroundColor(_ color: X.ColorMap?) -> some View {
        self.modifier(ColorModifier(foregroundColorMap: color, backgroundColorMap: nil))
    }
    public func xBackgroundColor(_ color: X.ColorMap?) -> some View {
        self.modifier(ColorModifier(foregroundColorMap: nil, backgroundColorMap: color))
    }
    public func xShadow(color: X.ColorMap?, radius: CGFloat, x: CGFloat, y: CGFloat, visible: Bool = true) -> some View {
        self.modifier(ShadowColorModifier(color: color, radius: radius, x: x, y: y, visible: visible))
    }
    public func xFont(_ font: LX.Font?) -> some View {
        self.modifier(FontModifier(font: font))
    }
}

// MARK: - INTERNAL HELPERS -
fileprivate struct ColorModifier: ViewModifier {
    let foregroundColorMap: X.ColorMap?
    let backgroundColorMap: X.ColorMap?

    func body(content: Content) -> some View {
        switch (foregroundColorMap, backgroundColorMap) {
        case (.some(let fg), .some(let bg)):
            content
                .environment(\.xForegroundColor, fg)
                .environment(\.xBackgroundColor, bg)
                .foregroundColor(fg.apply(colorScheme: colorScheme).asSUIColor)
                .background(bg.apply(colorScheme: colorScheme).asSUIColor)
        case (.some(let fg), .none):
            content
                .environment(\.xForegroundColor, fg)
                .foregroundColor(fg.apply(colorScheme: colorScheme).asSUIColor)
        case (.none, .some(let bg)):
            content
                .environment(\.xBackgroundColor, bg)
                .background(bg.apply(colorScheme: colorScheme).asSUIColor)
        case (.none, .none):
            content
        }
    }
    @Environment(\.colorScheme) private var colorScheme
}

fileprivate struct FontModifier: ViewModifier {
    let font: LX.Font?

    func body(content: Content) -> some View {
        content
            .environment(\.xFont, font)
    }
}

fileprivate struct ShadowColorModifier: ViewModifier {
    let color: X.ColorMap?
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    let visible: Bool
    @Environment(\.colorScheme) private var colorScheme
    func body(content: Content) -> some View {
        if let color = color.map({ $0.apply(colorScheme: colorScheme).asSUIColor }), visible == true {
            content
                .shadow(color: color, radius: radius, x: x, y: y)
        } else {
            content
        }
    }
}

// MARK: - FOREGROUND -
extension EnvironmentValues {
    public var xForegroundColor: X.ColorMap? {
        get { self[ForegroundColorKey.self] }
        set { self[ForegroundColorKey.self] = newValue }
    }
}

fileprivate struct ForegroundColorKey: EnvironmentKey {
    static let defaultValue: X.ColorMap? = nil // Default value is nil, indicating no custom color is set
}

// MARK: - BACKGROUND -
extension EnvironmentValues {
    public var xBackgroundColor: X.ColorMap? {
        get { self[BackgroundColorKey.self] }
        set { self[BackgroundColorKey.self] = newValue }
    }
}

fileprivate struct BackgroundColorKey: EnvironmentKey {
    static let defaultValue: X.ColorMap? = nil // Default value is nil, indicating no custom color is set
}

// MARK: - FONT -
extension EnvironmentValues {
    public var xFont: LX.Font? {
        get { self[XFontKey.self] }
        set { self[XFontKey.self] = newValue }
    }
}

fileprivate struct XFontKey: EnvironmentKey {
    static let defaultValue: LX.Font? = nil // Default value is nil, indicating no custom color is set
}
