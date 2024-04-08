//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/5/24.
//

import Foundation
import SwiftyDebug

extension IO {
    public struct State {
        public let text: Text
    }
}

extension IO.State {
    internal func `continue`<A>(value: A) -> IO.Parser<A>.Output {
        IO.Parser<A>.Output.continue(value: value, state: self)
    }
    internal func `break`<A>() -> IO.Parser<A>.Output {
        IO.Parser<A>.Output.break(state: self)
    }
    internal func set(text: IO.Text) -> Self {
        Self(text: text)
    }
}

// MARK: - DEBUG -
extension IO.State: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return PrettyTree(label: "IO.State", children: [
            PrettyTree(key: "text", value: PrettyTree.string(text.asString)),
        ])
    }
}
