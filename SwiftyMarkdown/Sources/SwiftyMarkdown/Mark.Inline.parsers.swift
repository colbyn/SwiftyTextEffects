//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/6/24.
//

import Foundation
import SwiftyParsec

extension Mark.Inline {
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        IO.Parser.options([
            Mark.Inline.Image.parser(env: env).map(Mark.Inline.image),
            Mark.Inline.Link.parser(env: env).map(Mark.Inline.link),
            Mark.Inline.Emphasis.parser(env: env).map(Mark.Inline.emphasis),
            Mark.Inline.Link.parser(env: env).map(Self.link),
            Mark.Inline.Image.parser(env: env).map(Self.image),
            Mark.Inline.Highlight.parser(env: env).map(Self.highlight),
            Mark.Inline.Strikethrough.parser(env: env).map(Self.strikethrough),
            Mark.Inline.Subscript.parser(env: env).map(Self.sub),
            Mark.Inline.Superscript.parser(env: env).map(Self.sup),
            Mark.Inline.InlineCode.parser(env: env).map(Self.inlineCode),
            Mark.Inline.PlainText.parser(env: env).map(Mark.Inline.plainText),
        ])
    }
    public static func many(env: Mark.Environment) -> IO.Parser<[Self]> {
        let terminator = IO.TextParser.token("\n\n")
        return Mark.Inline.parser(env: env).sequence(
            settings: .default
                .allowEmpty(true)
                .until(terminator: IO.ControlFlowParser.wrap(flip: terminator))
        )
    }
    public static func some(env: Mark.Environment) -> IO.Parser<[Self]> {
        let terminator = IO.TextParser.token("\n\n")
        return Mark.Inline.parser(env: env).sequence(
            settings: .default
                .allowEmpty(false)
                .until(terminator: IO.ControlFlowParser.wrap(flip: terminator))
        )
    }
    public static func painTextParser(env: Mark.Environment) -> IO.TextParser {
        let terminal = env.inlineTerminators.or(try: IO.TextParser.token("\n"))
        let results = IO.CharParser.pop.sequence(
            settings: .default
                .allowEmpty(false)
                .until(terminator: IO.ControlFlowParser.wrap(flip: terminal))
        )
        return results.map(IO.Text.init(from:))
    }
    public static var lineBreak: IO.Parser<Self> {
        IO.CharParser.newline
            .map(Mark.Inline.lineBreak)
    }
}

extension Mark.Inline.PlainText {
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        Mark.Inline
            .painTextParser(env: env.withScope(inline: .plainText))
            .map(Mark.Inline.PlainText.init(value:))
    }
}
extension Mark.Inline.Link {
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        let text = Mark.Inline.InSquareBrackets
            .parser(
                content: Mark.Inline.many(
                    env: .root.withScope(inline: .link(.inSquareBraces))
                )
            )
        let url = Mark.Inline
            .painTextParser(
                env: .root.withScope(inline: .link(.inRoundBraces))
            )
            .between(
                leading: IO.CharParser.pop(char: "("),
                trailing: IO.CharParser.pop(char: ")")
            )
        let parser = IO.Tuple.join(f: text, g: url).map {
            Self(
                text: $0.a,
                openRoundBracket: $0.b.a,
                destination: $0.b.b,
                title: nil,
                closeRoundBracket: $0.b.c
            )
        }
        return parser
    }
}
extension Mark.Inline.Image {
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        let bang = IO.CharParser.pop(char: "!")
        let link = Mark.Inline.Link.parser(env: env)
        let parser = IO.Tuple.join(f: bang, g: link).map {
            Self(bang: $0.a, link: $0.b)
        }
        return parser
    }
}
extension Mark.Inline.Emphasis {
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        let pack: (Mark.Environment.Scope.Inline.EmphasisType) -> IO.Parser<Self> = { type in
            let env = env.withScope(inline: .emphasis(type))
            let content = Mark.Inline.many(env: env)
            return content
                .between(bothEnds: IO.TextParser.token(type.asString))
                .map {
                    Self(startDelimiter: $0.a, content: $0.b, endDelimiter: $0.c)
                }
        }
        return IO.Parser.options([
            pack(.triple("*")), // `***`
            pack(.double("*")), // `**`
            pack(.single("*")), // `*`
            pack(.triple("_")), // `___`
            pack(.double("_")), // `__`
            pack(.single("_")), // `_`
        ])
    }
}
extension Mark.Inline.Highlight {
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        let env = env.withScope(inline: .highlight)
        let content = Mark.Inline.many(env: env)
        return content
            .between(bothEnds: IO.TextParser.token("=="))
            .map {
                Self(startDelimiter: $0.a, content: $0.b, endDelimiter: $0.c)
            }
    }
}
extension Mark.Inline.Strikethrough {
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        let env = env.withScope(inline: .strikethrough)
        let content = Mark.Inline.many(env: env)
        return content
            .between(bothEnds: IO.TextParser.token("~~"))
            .map {
                Self(startDelimiter: $0.a, content: $0.b, endDelimiter: $0.c)
            }
    }
}
extension Mark.Inline.Subscript {
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        let env = env.withScope(inline: .sub)
        let content = Mark.Inline.many(env: env)
        return content
            .between(bothEnds: IO.TextParser.token("~"))
            .map {
                Self(startDelimiter: $0.a, content: $0.b, endDelimiter: $0.c)
            }
    }
}
extension Mark.Inline.Superscript {
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        let env = env.withScope(inline: .sub)
        let content = Mark.Inline.many(env: env)
        return content
            .between(bothEnds: IO.TextParser.token("^"))
            .map {
                Self(startDelimiter: $0.a, content: $0.b, endDelimiter: $0.c)
            }
    }
}
extension Mark.Inline.InlineCode {
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        let pack: (String) -> IO.Parser<Self> = {
            let token = IO.TextParser.token($0)
            let rest = IO.CharParser.pop
                .manyTill(terminator: token)
                .map {
                    $0.mapA(IO.Text.init(from:))
                }
            return IO.Tuple.join(f: token, g: rest).map {
                Self(startDelimiter: $0.a, content: $0.b.a, endDelimiter: $0.b.b)
            }
        }
        return IO.Parser.options([
            pack("``"),
            pack("`"),
        ])
    }
}
extension Mark.Inline.InDoubleQuotes {
    public static func parser(
        content parser: @autoclosure @escaping () -> IO.Parser<Content>
    ) -> IO.Parser<Self> {
        parser()
            .between(bothEnds: IO.CharParser.pop(char: "\""))
            .map {
                Self(startDelimiter: $0.a, content: $0.b, endDelimiter: $0.c)
            }
    }
}
extension Mark.Inline.InSquareBrackets {
    public static func parser(
        content parser: @autoclosure @escaping () -> IO.Parser<Content>
    ) -> IO.Parser<Self> {
        parser()
            .between(leading: IO.CharParser.pop(char: "["), trailing: IO.CharParser.pop(char: "]"))
            .map {
                Self(openDelimiter: $0.a, content: $0.b, closeDelimiter: $0.c)
            }
    }
}
extension Mark.Inline.Latex {
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        fatalError("TODO")
    }
}
