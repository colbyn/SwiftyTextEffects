//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/6/24.
//

import Foundation
import SwiftyParsec

extension Mark {
    public enum Inline {
        case plainText(PlainText)
        case link(Link)
        case image(Image)
        case emphasis(Emphasis)
        case highlight(Highlight)
        case strikethrough(Strikethrough)
        case sub(Subscript)
        case sup(Superscript)
        case inlineCode(InlineCode)
        case latex(Latex)
        case lineBreak(Token.FatChar)
        case raw(Text)
        public struct PlainText {
            public let value: Text
        }
        public struct Link {
            public let text: InSquareBrackets<[Mark.Inline]>
            public let openRoundBracket: Token.FatChar
            public let destination: Text
            public let title: InDoubleQuotes<Text>?
            public let closeRoundBracket: Token.FatChar
        }
        public struct Image {
            public let bang: Token.FatChar
            public let link: Link
        }
        public struct Emphasis {
            /// Could be `*` or `_`, up to three repeating characters of such.
            public let startDelimiter: Token
            public let content: [Inline]
            public let endDelimiter: Token
        }
        public struct Highlight {
            /// Assuming `==` for start
            public let startDelimiter: Token
            public let content: [Inline]
            /// Assuming `==` for end
            public let endDelimiter: Token
        }
        public struct Strikethrough {
            /// Assuming `~~` for start
            public let startDelimiter: Token
            public let content: [Inline]
            /// Assuming `~~` for end
            public let endDelimiter: Token
        }
        public struct Subscript {
            /// Assuming `~` for start
            public let startDelimiter: Token
            public let content: [Inline]
            /// Assuming `~` for end
            public let endDelimiter: Token
        }
        public struct Superscript {
            /// Assuming `^` for start
            public let startDelimiter: Token
            public let content: [Inline]
            /// Assuming `^` for end
            public let endDelimiter: Token
        }
        public struct InlineCode {
            /// One or more backticks.
            public let startDelimiter: Token
            public let content: Text
            /// One or more backticks; matching the `startDelimiter`.
            public let endDelimiter: Token
        }
        public struct InDoubleQuotes<Content> {
            public let startDelimiter: Token.FatChar
            public let content: Content
            public let endDelimiter: Token.FatChar
        }
        public struct InSquareBrackets<Content> {
            public let openDelimiter: Token.FatChar
            public let content: Content
            public let closeDelimiter: Token.FatChar
            public func map<Result>(_ function: @escaping (Content) -> Result) -> InSquareBrackets<Result> {
                InSquareBrackets<Result>(openDelimiter: openDelimiter, content: function(content), closeDelimiter: closeDelimiter)
            }
        }
        public struct Latex {
            /// Either a single dollar sign (`$`) or double dollar signs (`$$`).
            public let startDelimiter: Token
            /// The Tex/LaTeX literal content.
            public let content: Text
            /// Either a single dollar sign (`$`) or double dollar signs (`$$`); matching the start token.
            public let endDelimiter: Token
        }
    }
}

