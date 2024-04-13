//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 3/2/24.
//


import Foundation

#if os(iOS)
#elseif os(macOS)
#endif

#if os(macOS)
#endif

#if os(iOS)
import UIKit
import protocol SwiftUI.UIViewRepresentable
import protocol SwiftUI.UIViewControllerRepresentable
import class    SwiftUI.UIHostingController
#elseif os(macOS)
import AppKit
import protocol SwiftUI.NSViewRepresentable
import protocol SwiftUI.NSViewControllerRepresentable
import class    SwiftUI.NSHostingController
#endif

/// The 'low-level' namespace.
public struct LX {}

#if os(iOS)
extension LX {
    public typealias ViewRepresentable = SwiftUI.UIViewRepresentable
    public typealias ViewControllerRepresentable = SwiftUI.UIViewControllerRepresentable
    public typealias HostingController = SwiftUI.UIHostingController
    public typealias View = UIView
    public typealias StackView = UIStackView
    public typealias TextView = UITextView
    public typealias TextViewDelegate = UITextViewDelegate
    public typealias ViewController = UIViewController
    public typealias ScrollView = UIScrollView
    public typealias Font = UIFont
    public typealias Menu = UIMenu
    public typealias Image = UIImage
    public typealias GestureRecognizer = UIGestureRecognizer
    public typealias Color = UIColor
}
#elseif os(macOS)
extension LX {
    public typealias ViewRepresentable = SwiftUI.NSViewRepresentable
    public typealias ViewControllerRepresentable = SwiftUI.NSViewControllerRepresentable
    public typealias HostingController = SwiftUI.NSHostingController
    public typealias View = NSView
    public typealias StackView = NSStackView
    public typealias TextView = NSTextView
    public typealias TextViewDelegate = NSTextViewDelegate
    public typealias ViewController = NSViewController
    public typealias ScrollView = NSScrollView
    public typealias Font = NSFont
    public typealias Menu = NSMenu
    public typealias Image = NSImage
    public typealias GestureRecognizer = NSGestureRecognizer
    public typealias Color = NSColor
}
#endif
