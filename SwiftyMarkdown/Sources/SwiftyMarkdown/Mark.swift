//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/6/24.
//

import Foundation
import SwiftyParsec
import SwiftyDebug

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
