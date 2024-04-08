//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/5/24.
//

import Foundation
import SwiftyDebug

extension IO.Text {
    /// A `FatChar` is a Swift `Character` with metadata denoting its original source code position.
    ///
    /// Represents an annotated character within the `Tape`, including its value and position in the original input.
    public struct FatChar {
        public let value: Character
        public let index: PositionIndex
    }
    /// Models the position of a character in the input, supporting detailed parsing error messages and context analysis.
    public struct PositionIndex {
        public let character: UInt
        public let column: UInt
        public let line: UInt
        public static let zero = Self(character: 0, column: 0, line: 0)
        /// Advances the position index based on the given character, accommodating line breaks.
        internal func advance(for character: Character) -> Self {
            if character.isNewline {
                return Self(character: self.character + 1, column: 0, line: line + 1)
            }
            return Self(character: self.character + 1, column: column + 1, line: line)
        }
    }
}
extension IO {
    public typealias CharParser = IO.Parser<IO.Text.FatChar>
}

extension IO.Text.FatChar {
    public var singleton: IO.Text {
        IO.Text(singleton: self)
    }
}

// MARK: - DEBUG -
extension IO.Text.FatChar: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return .value("Text.FatChar(\(value.debugDescription))")
    }
}
