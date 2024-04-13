//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 3/2/24.
//

import Foundation
import SwiftUI


#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif



extension X {
    public struct WrapView<LLViewType: LX.View>: LX.ViewRepresentable {
#if os(iOS)
        public typealias LLViewType = LLViewType
#elseif os(macOS)
        public typealias NSViewType = LLViewType
#endif
        public typealias Updater = (LLViewType, Context) -> Void
        
        fileprivate var makeView: (Context) -> LLViewType
        fileprivate var update: (LLViewType, Context) -> ()
        
        public init(_ setup: @escaping () -> LLViewType) {
            self.makeView = { _ in setup()}
            self.update = {(_, _) in ()}
        }
        public init(setup: @escaping (Context) -> LLViewType, update: @escaping (LLViewType) -> ()) {
            self.makeView = setup
            self.update = {(wrapper, _) in update(wrapper)}
        }
#if os(iOS)
        public func makeUIView(context: Context) -> LLViewType {
            return makeView(context)
        }
        public func updateUIView(_ view: LLViewType, context: Context) {
            update(view, context)
        }
#elseif os(macOS)
        public func makeNSView(context: Context) -> LLViewType {
            return makeView(context)
        }
        public func updateNSView(_ view: LLViewType, context: Context) {
            update(view, context)
        }
#endif
    }
}



