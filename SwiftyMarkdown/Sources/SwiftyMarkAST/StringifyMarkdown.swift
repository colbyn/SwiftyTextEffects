//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/6/24.
//

import Foundation
import SwiftyParsec

/// Internal for now.
public protocol StringifyMarkdown {
    var stringify: String { get }
}

extension IO.Text: StringifyMarkdown {
    public var stringify: String {
        asString
    }
}
extension IO.Text.FatChar: StringifyMarkdown {
    public var stringify: String {
        singleton.asString
    }
}
extension Optional: StringifyMarkdown where Wrapped: StringifyMarkdown {
    public var stringify: String {
        if let x = self {
            return x.stringify
        }
        return ""
    }
}
