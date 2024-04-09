//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/6/24.
//

import Foundation
import SwiftyParsec
import SwiftyDebug

/// The root Markdown AST for both inline and block/display nodes.
public enum Mark {
    case inline(Inline), block(Block)
    
    public typealias Text = IO.Text
    public typealias Token = IO.Text
}

// MARK: - DEBUG -
extension Mark: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        switch self {
        case .block(let x): return x.asPrettyTree
        case .inline(let x): return x.asPrettyTree
        }
    }
}

extension Mark.Inline {
    public static let reservedTokens: Set<String> = [
        "[",
        "]",
        "(",
        ")",
        "*",
        "_",
        "=",
        "~",
        "`",
    ]
}

extension Mark {
    public static func parse(source: String) -> [Self] {
        let (result1, state) = Self.some(env: .root).evaluate(source: source)
        var result2 = result1 ?? []
        let unparsed = state.text
        if !unparsed.isEmpty {
            result2.append(.inline(.raw(unparsed)))
        }
        return result2
    }
}
