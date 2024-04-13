//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 3/2/24.
//

import Foundation
import struct SwiftUI.Color

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension X {
#if os(iOS)
    public typealias Color = UIKit.UIColor
#elseif os(macOS)
    public typealias Color = AppKit.NSColor
#endif
}

public extension X.Color {
    /// Returns a SwiftUI `Color` object.
    var asSUIColor: SwiftUI.Color { SwiftUI.Color(self) }
}

