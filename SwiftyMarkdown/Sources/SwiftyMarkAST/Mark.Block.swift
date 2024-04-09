//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/6/24.
//

import Foundation
import SwiftyParsec

extension Mark {
    public enum Block {
        case heading(Heading)
        case paragraph(Paragraph)
        case blockquote(Blockquote)
        case list(List)
        case fencedCodeBlock(FencedCodeBlock)
        case horizontalRule(HorizontalRule)
        case table(Table)
        case newline(Token.FatChar)
        public struct Heading {
            /// Markdown allows for 1-6 `#` characters for headings
            public let hashTokens: Token
            public let content: [ Inline ]
        }
        public struct Paragraph {
            /// A paragraph can contain multiple text elements
            public let content: [Inline]
        }
        public struct Blockquote {
            /// The `>` character used to denote blockquotes
            public let startDelimiters: [Token]
            /// Blockquotes can contain multiple other Markdown elements
            public let content: [ Mark ]
        }
        public struct FencedCodeBlock {
            /// The sequence of `` ` `` or `~` characters that start the block
            public let fenceStart: Token
            /// Optional language identifier for syntax highlighting
            public let infoString: Text?
            /// The actual code content
            public let content: Text
            /// The sequence of `` ` `` or `~` characters that end the block
            public let fenceEnd: Token
        }
        public struct HorizontalRule {
            /// The characters used to create a horizontal rule, e.g., `---`, `***`, `___`
            public let tokens: Token
        }
        public struct Table {
            public let header: Header
            public let data: [ Row ]
        }
    }
}

extension Mark.Block {
    public enum List {
        case unordered(list: [UnorderedItem])
        case ordered(list: [OrderedItem])
        case task(list: [TaskItem])
        public struct UnorderedItem {
            /// Either `*`, `-`, `+`, or a number followed by `.`
            public let bullet: Mark.Token.FatChar
            public let content: [ Mark ]
        }
        public struct OrderedItem {
            public let number: Mark.Token
            public let dot: Mark.Token.FatChar
            public let content: [ Mark ]
        }
        public struct TaskItem {
            public let bullet: Mark.Token.FatChar
            /// Represents the `[ ]` or `[x]` for task list items
            public let header: Mark.Inline.InSquareBrackets<Mark.Token?>
            /// Task list items can contain multiple other Markdown elements
            public let content: [ Mark ]
        }
    }
}

extension Mark.Block.Table {
    public struct Header {
        public let header: Row
        public let separator: SeperatorRow
    }
    public struct SeperatorRow {
        /// Optionally, a table row might start with a delimiter if the table format specifies it.
        public let startDelimiter: Mark.Token.FatChar?
        /// The cells within the row.
        public let columns: [ Cell ]
        public struct Cell {
            public let startColon: Mark.Token.FatChar?
            public let dashes: Mark.Token
            public let endColon: Mark.Token.FatChar?
            public let endDelimiter: Mark.Token.FatChar?
        }
    }
    public struct Row {
        /// Optionally, a table row might start with a delimiter if the table format specifies it.
        public let startDelimiter: Mark.Token.FatChar?
        /// The cells within the row.
        public let cells: [ Cell ]
        public struct Cell {
            /// Content of the cell. This could include inline formatting, links, etc.
            public let content: [ Mark.Inline ]
            /// Delimiter token to separate this cell from the next. This could be considered optional,
            /// as the last cell in a row might not have a trailing delimiter in some Markdown formats.
            public let pipeDelimiter: Mark.Token.FatChar?
        }
    }
}
