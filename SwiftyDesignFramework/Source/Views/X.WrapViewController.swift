//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 3/3/24.
//

import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension X {
    public struct WrapViewController<LLViewControllerType: LX.ViewController>: LX.ViewControllerRepresentable {
#if os(iOS)
        public typealias UIViewControllerType = LLViewControllerType
#elseif os(macOS)
        public typealias NSViewControllerType = LLViewControllerType
#endif
        typealias Updater = (LLViewControllerType, Context) -> Void
        fileprivate var makeViewCtl: (Context) -> LLViewControllerType
        fileprivate var update: (LLViewControllerType, Context) -> ()
        public init(_ setup: @escaping () -> LLViewControllerType) {
            self.makeViewCtl = {_ in setup()}
            self.update = { _, _ in }
        }
        public init(
            setup: @escaping (Context) -> LLViewControllerType,
            update: @escaping (LLViewControllerType, Context) -> ()
        ) {
            self.makeViewCtl = setup
            self.update = update
        }
#if os(iOS)
        public func makeUIViewController(context: Self.Context) -> LLViewControllerType {
            makeViewCtl(context)
        }
        public func updateUIViewController(_ ctl: LLViewControllerType, context: Self.Context) {
            update(ctl, context)
        }
#elseif os(macOS)
        public func makeNSViewController(context: Self.Context) -> LLViewControllerType {
            let ctl = makeViewCtl(context)
            return ctl
        }
        public func updateNSViewController(_ ctl: LLViewControllerType, context: Self.Context) {
            update(ctl, context)
        }
#endif
    }
    
}


