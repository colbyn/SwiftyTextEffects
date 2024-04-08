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

