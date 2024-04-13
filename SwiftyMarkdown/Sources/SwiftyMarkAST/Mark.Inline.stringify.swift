//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/6/24.
//

import Foundation

extension Mark.Inline: StringifyMarkdown {
    public var stringify: String {
        switch self {
        case .plainText(let x): return x.stringify
        case .link(let x): return x.stringify
        case .image(let x): return x.stringify
        case .emphasis(let x): return x.stringify
        case .highlight(let x): return x.stringify
        case .strikethrough(let x): return x.stringify
        case .sub(let x): return x.stringify
        case .sup(let x): return x.stringify
        case .inlineCode(let x): return x.stringify
        case .latex(let x): return x.stringify
        case .lineBreak(let x): return x.singleton.asString
        case .raw(let x): return x.asString
        }
    }
}

extension Mark.Inline.PlainText: StringifyMarkdown {
    public var stringify: String {
        self.value.asString
    }
}
extension Mark.Inline.Link: StringifyMarkdown {
    public var stringify: String {
        let text = "[\(text.content.map { $0.stringify })]"
        let destination = destination.stringify
        let title = title.stringify
        if title.isEmpty {
            return "\(text)(\(destination))"
        }
        return "\(text)(\(destination) \(title))"
    }
}
extension Mark.Inline.Image: StringifyMarkdown {
    public var stringify: String {
        let link = link.stringify
        return "!\(link)"
    }
}
extension Mark.Inline.Emphasis: StringifyMarkdown {
    public var stringify: String {
        let startDelimiter = startDelimiter.stringify
        let content = content.map { $0.stringify }.joined(separator: "")
        let endDelimiter = endDelimiter.stringify
        return "\(startDelimiter)\(content)\(endDelimiter)"
    }
}
extension Mark.Inline.Highlight: StringifyMarkdown {
    public var stringify: String {
        let startDelimiter = startDelimiter.stringify
        let content = content.map { $0.stringify }.joined(separator: "")
        let endDelimiter = endDelimiter.stringify
        return "\(startDelimiter)\(content)\(endDelimiter)"
    }
}
extension Mark.Inline.Strikethrough: StringifyMarkdown {
    public var stringify: String {
        let startDelimiter = startDelimiter.stringify
        let content = content.map { $0.stringify }.joined(separator: "")
        let endDelimiter = endDelimiter.stringify
        return "\(startDelimiter)\(content)\(endDelimiter)"
    }
}
extension Mark.Inline.Subscript: StringifyMarkdown {
    public var stringify: String {
        let startDelimiter = startDelimiter.stringify
        let content = content.map { $0.stringify }.joined(separator: "")
        let endDelimiter = endDelimiter.stringify
        return "\(startDelimiter)\(content)\(endDelimiter)"
    }
}
extension Mark.Inline.Superscript: StringifyMarkdown {
    public var stringify: String {
        let startDelimiter = startDelimiter.stringify
        let content = content.map { $0.stringify }.joined(separator: "")
        let endDelimiter = endDelimiter.stringify
        return "\(startDelimiter)\(content)\(endDelimiter)"
    }
}
extension Mark.Inline.InlineCode: StringifyMarkdown {
    public var stringify: String {
        let startDelimiter = startDelimiter.stringify
        let content = content.stringify
        let endDelimiter = endDelimiter.stringify
        return "\(startDelimiter)\(content)\(endDelimiter)"
    }
}
extension Mark.Inline.InDoubleQuotes: StringifyMarkdown where Content: StringifyMarkdown {
    public var stringify: String {
        let openQuote = startDelimiter.stringify
        let content = content.stringify
        let closeQuote = endDelimiter.stringify
        return "\(openQuote)\(content)\(closeQuote)"
    }
}
extension Mark.Inline.InSquareBrackets: StringifyMarkdown where Content: StringifyMarkdown {
    public var stringify: String {
        let openSquareBracket = openDelimiter.stringify
        let content = content.stringify
        let closeSquareBracket = closeDelimiter.stringify
        return "\(openSquareBracket)\(content)\(closeSquareBracket)"
    }
}
extension Mark.Inline.Latex: StringifyMarkdown {
    public var stringify: String {
        let start = startDelimiter.stringify
        let content = content.stringify
        let close = endDelimiter.stringify
        return "\(start)\(content)\(close)"
    }
}
