//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/6/24.
//

import Foundation
import SwiftyParsec

internal protocol Stringify {
    var stringify: String { get }
}

extension IO.Text: Stringify {
    public var stringify: String {
        asString
    }
}
extension IO.Text.FatChar: Stringify {
    public var stringify: String {
        singleton.asString
    }
}
extension Optional: Stringify where Wrapped: Stringify {
    internal var stringify: String {
        if let x = self {
            return x.stringify
        }
        return ""
    }
}
