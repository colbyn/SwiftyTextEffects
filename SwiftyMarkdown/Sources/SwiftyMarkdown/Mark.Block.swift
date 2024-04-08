//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/6/24.
//

import Foundation
import SwiftyParsec
import SwiftyDebug

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

// MARK: - DEBUG -
extension Mark.Block {
    public var asPrettyTree: PrettyTree {
        switch self {
        case .heading(let x): return x.asPrettyTree
        case .paragraph(let x): return x.asPrettyTree
        case .blockquote(let x): return x.asPrettyTree
        case .list(let x): return x.asPrettyTree
        case .fencedCodeBlock(let x): return x.asPrettyTree
        case .horizontalRule(let x): return x.asPrettyTree
        case .table(let x): return x.asPrettyTree
        case .newline(let x): return .init(key: "newline", value: x)
        }
    }
}
extension Mark.Block.Heading: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return PrettyTree(label: "Block.Heading", children: [
            .init(key: "hashTokens", value: hashTokens),
            .init(key: "content", value: content),
        ])
    }
}
extension Mark.Block.Paragraph: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return PrettyTree(label: "Block.Paragraph", children: [
            .init(key: "content", value: content),
        ])
    }
}
extension Mark.Block.Blockquote: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return PrettyTree(label: "Block.Blockquote", children: [
            .init(key: "startDelimiters", value: startDelimiters),
            .init(key: "content", value: content),
        ])
    }
}
extension Mark.Block.List: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        switch self {
        case .ordered(list: let xs): return .init(label: "Mark.Block.List.ordered", children: xs)
        case .unordered(list: let xs): return .init(label: "Mark.Block.List.unordered", children: xs)
        case .task(list: let xs): return .init(label: "Mark.Block.List.task", children: xs)
        }
    }
}
extension Mark.Block.List.UnorderedItem: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return .init(label: "Mark.Block.List.UnorderedItem", children: [
            .init(key: "bullet", value: bullet),
            .init(key: "content", value: content),
        ])
    }
}
extension Mark.Block.List.OrderedItem: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return .init(label: "Mark.Block.List.OrderedItem", children: [
            .init(key: "number", value: number),
            .init(key: "dot", value: dot),
            .init(key: "content", value: content),
        ])
    }
}
extension Mark.Block.List.TaskItem: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return .init(label: "Mark.Block.List.TaskItem", children: [
            .init(key: "bullet", value: bullet),
            .init(key: "header", value: header),
            .init(key: "content", value: content),
        ])
    }
}
extension Mark.Block.FencedCodeBlock: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return PrettyTree(label: "Block.FencedCodeBlock", children: [
            .init(key: "fenceStart", value: fenceStart),
            .init(key: "infoString", value: infoString),
            .init(key: "content", value: content),
            .init(key: "fenceEnd", value: fenceEnd),
        ])
    }
}
extension Mark.Block.HorizontalRule: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return PrettyTree(label: "Block.HorizontalRule", children: [
            .init(key: "tokens", value: tokens)
        ])
    }
}
extension Mark.Block.Table: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return PrettyTree(label: "Block.Table", children: [
            .init(key: "header", value: header),
            .init(key: "data", value: data),
        ])
    }
}
extension Mark.Block.Table.Header: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        .init(label: "Block.Table.Header", children: [
            .init(key: "header", value: header),
            .init(key: "separator", value: separator),
        ])
    }
}
extension Mark.Block.Table.SeperatorRow: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        .init(label: "Block.Table.SeperatorRow", children: [
            .init(key: "startDelimiter", value: startDelimiter),
            .init(key: "columns", value: columns),
        ])
    }
}
extension Mark.Block.Table.SeperatorRow.Cell: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        .init(label: "Block.Table.SeperatorRow.Cell", children: [
            .init(key: "startColon", value: startColon),
            .init(key: "dashes", value: dashes),
            .init(key: "endColon", value: endColon),
            .init(key: "endDelimiter", value: endDelimiter),
        ])
    }
}
extension Mark.Block.Table.Row: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return PrettyTree(label: "Block.Table.Row", children: [
            .init(key: "startDelimiter", value: startDelimiter),
            .init(key: "cells", value: cells),
        ])
    }
}
extension Mark.Block.Table.Row.Cell: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        .init(label: "Block.Table.Row.Cell", children: [
            .init(key: "content", value: content),
            .init(key: "pipeDelimiter", value: pipeDelimiter),
        ])
    }
}
