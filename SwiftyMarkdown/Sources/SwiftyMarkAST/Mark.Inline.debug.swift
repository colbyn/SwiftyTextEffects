//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/8/24.
//

import Foundation
import SwiftyDebug

// MARK: - DEBUG -
extension Mark.Inline: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        switch self {
        case .plainText(let x): return x.asPrettyTree
        case .link(let x): return x.asPrettyTree
        case .image(let x): return x.asPrettyTree
        case .emphasis(let x): return x.asPrettyTree
        case .highlight(let x): return x.asPrettyTree
        case .strikethrough(let x): return x.asPrettyTree
        case .sub(let x): return x.asPrettyTree
        case .sup(let x): return x.asPrettyTree
        case .inlineCode(let x): return x.asPrettyTree
        case .latex(let x): return x.asPrettyTree
        case .lineBreak(let x): return x.asPrettyTree
        case .raw(let x): return .init(key: ".raw", value: x)
        }
    }
}
extension Mark.Inline.PlainText: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return .init(key: "Inline.PlainText", value: value)
    }
}
extension Mark.Inline.Link: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return PrettyTree(label: "Inline.Link", children: [
            .init(key: "text", value: text),
            .init(key: "openRoundBracket", value: openRoundBracket),
            .init(key: "destination", value: destination),
            .init(key: "title", value: title),
            .init(key: "closeRoundBracket", value: closeRoundBracket),
        ])
    }
}
extension Mark.Inline.Image: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return PrettyTree(label: "Inline.Image", children: [
            .init(key: "bang", value: bang),
            .init(key: "link", value: link),
        ])
    }
}
extension Mark.Inline.Emphasis: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return PrettyTree(label: "Inline.Emphasis", children: [
            .init(key: "startDelimiter", value: startDelimiter),
            .init(key: "content", value: content),
            .init(key: "endDelimiter", value: endDelimiter),
        ])
    }
}
extension Mark.Inline.Highlight: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return PrettyTree(label: "Inline.Highlight", children: [
            .init(key: "startDelimiter", value: startDelimiter),
            .init(key: "content", value: content),
            .init(key: "endDelimiter", value: endDelimiter),
        ])
    }
}
extension Mark.Inline.Strikethrough: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return PrettyTree(label: "Inline.Strikethrough", children: [
            .init(key: "startDelimiter", value: startDelimiter),
            .init(key: "content", value: content),
            .init(key: "endDelimiter", value: endDelimiter),
        ])
    }
}
extension Mark.Inline.Subscript: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return PrettyTree(label: "Inline.Subscript", children: [
            .init(key: "startDelimiter", value: startDelimiter),
            .init(key: "content", value: content),
            .init(key: "endDelimiter", value: endDelimiter),
        ])
    }
}
extension Mark.Inline.Superscript: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return PrettyTree(label: "Inline.Superscript", children: [
            .init(key: "startDelimiter", value: startDelimiter),
            .init(key: "content", value: content),
            .init(key: "endDelimiter", value: endDelimiter),
        ])
    }
}
extension Mark.Inline.InlineCode: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return PrettyTree(label: "Inline.InlineCode", children: [
            .init(key: "startDelimiter", value: startDelimiter),
            .init(key: "content", value: content),
            .init(key: "endDelimiter", value: endDelimiter),
        ])
    }
}
extension Mark.Inline.Latex: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        .init(label: "Latex", children: [
            .init(key: "startDelimiter", value: startDelimiter),
            .init(key: "content", value: content),
            .init(key: "endDelimiter", value: endDelimiter),
        ])
    }
}
extension Mark.Inline.InDoubleQuotes: ToPrettyTree where Content: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        .init(label: "Inline.InDoubleQuotes", children: [
            .init(key: "startDelimiter", value: startDelimiter),
            .init(key: "content", value: content),
            .init(key: "endDelimiter", value: endDelimiter),
        ])
    }
}
extension Mark.Inline.InSquareBrackets: ToPrettyTree where Content: ToPrettyTree {
     public var asPrettyTree: PrettyTree {
         .init(label: "Inline.InSquareBrackets", children: [
            .init(key: "openDelimiter", value: openDelimiter),
            .init(key: "content", value: content),
            .init(key: "closeDelimiter", value: closeDelimiter),
         ])
     }
 }

