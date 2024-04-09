//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/8/24.
//

import Foundation
import SwiftyDebug

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
