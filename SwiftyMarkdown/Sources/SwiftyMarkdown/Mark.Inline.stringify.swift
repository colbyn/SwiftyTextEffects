//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/6/24.
//

import Foundation

extension Mark.Inline: Stringify {
    internal var stringify: String {
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

extension Mark.Inline.PlainText: Stringify {
    internal var stringify: String {
        self.value.asString
    }
}
extension Mark.Inline.Link: Stringify {
    internal var stringify: String {
        let text = "[\(text.content.map { $0.stringify })]"
        let destination = destination.stringify
        let title = title.stringify
        return "\(text)(\(destination) \(title))"
    }
}
extension Mark.Inline.Image: Stringify {
    internal var stringify: String {
        let link = link.stringify
        return "!\(link)"
    }
}
extension Mark.Inline.Emphasis: Stringify {
    internal var stringify: String {
        let startDelimiter = startDelimiter.stringify
        let content = content.map { $0.stringify }.joined(separator: "")
        let endDelimiter = endDelimiter.stringify
        return "\(startDelimiter)\(content)\(endDelimiter)"
    }
}
extension Mark.Inline.Highlight: Stringify {
    internal var stringify: String {
        let startDelimiter = startDelimiter.stringify
        let content = content.map { $0.stringify }.joined(separator: "")
        let endDelimiter = endDelimiter.stringify
        return "\(startDelimiter)\(content)\(endDelimiter)"
    }
}
extension Mark.Inline.Strikethrough: Stringify {
    internal var stringify: String {
        let startDelimiter = startDelimiter.stringify
        let content = content.map { $0.stringify }.joined(separator: "")
        let endDelimiter = endDelimiter.stringify
        return "\(startDelimiter)\(content)\(endDelimiter)"
    }
}
extension Mark.Inline.Subscript: Stringify {
    internal var stringify: String {
        let startDelimiter = startDelimiter.stringify
        let content = content.map { $0.stringify }.joined(separator: "")
        let endDelimiter = endDelimiter.stringify
        return "\(startDelimiter)\(content)\(endDelimiter)"
    }
}
extension Mark.Inline.Superscript: Stringify {
    internal var stringify: String {
        let startDelimiter = startDelimiter.stringify
        let content = content.map { $0.stringify }.joined(separator: "")
        let endDelimiter = endDelimiter.stringify
        return "\(startDelimiter)\(content)\(endDelimiter)"
    }
}
extension Mark.Inline.InlineCode: Stringify {
    internal var stringify: String {
        let startDelimiter = startDelimiter.stringify
        let content = content.stringify
        let endDelimiter = endDelimiter.stringify
        return "\(startDelimiter)\(content)\(endDelimiter)"
    }
}
extension Mark.Inline.InDoubleQuotes: Stringify where Content: Stringify {
    internal var stringify: String {
        let openQuote = startDelimiter.stringify
        let content = content.stringify
        let closeQuote = endDelimiter.stringify
        return "\(openQuote)\(content)\(closeQuote)"
    }
}
extension Mark.Inline.InSquareBrackets: Stringify where Content: Stringify {
    internal var stringify: String {
        let openSquareBracket = openDelimiter.stringify
        let content = content.stringify
        let closeSquareBracket = closeDelimiter.stringify
        return "\(openSquareBracket)\(content)\(closeSquareBracket)"
    }
}
extension Mark.Inline.Latex: Stringify {
    internal var stringify: String {
        let start = startDelimiter.stringify
        let content = content.stringify
        let close = endDelimiter.stringify
        return "\(start)\(content)\(close)"
    }
}
