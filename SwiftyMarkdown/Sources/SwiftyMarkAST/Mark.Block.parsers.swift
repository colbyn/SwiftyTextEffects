//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/6/24.
//

import Foundation
import SwiftyParsec

extension Mark.Block {
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        IO.Parser.options([
            IO.CharParser.newline.map(Self.newline),
            Mark.Block.Heading.parser(env: env).map(Self.heading),
            Mark.Block.FencedCodeBlock.parser(env: env).map(Self.fencedCodeBlock),
            Mark.Block.HorizontalRule.parser(env: env).map(Self.horizontalRule),
            Mark.Block.Blockquote.parser(env: env).map(Self.blockquote),
            Mark.Block.List.parser(env: env).map(Self.list),
            Mark.Block.Table.parser(env: env).map(Self.table),
            Mark.Block.Paragraph.parser(env: env).map(Self.paragraph),
        ])
    }
    public static func many(env: Mark.Environment) -> IO.Parser<[Self]> {
        return Mark.Block.parser(env: env).sequence(
            settings: .default.allowEmpty(true)
        )
    }
    public static func some(env: Mark.Environment) -> IO.Parser<[Self]> {
        return Mark.Block.parser(env: env).sequence(
            settings: .default.allowEmpty(false)
        )
    }
}

extension Mark.Block.Heading {
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        let env = env.withScope(block: .heading)
        let hashes = IO.Parser.options([
            IO.TextParser.token("######"),
            IO.TextParser.token("#####"),
            IO.TextParser.token("####"),
            IO.TextParser.token("###"),
            IO.TextParser.token("##"),
            IO.TextParser.token("#"),
        ])
        let content = Mark.Inline.many(env: env)
        return IO.Tuple
            .join(f: hashes.spacedRight, g: content)
            .map {
                Self(hashTokens: $0.a, content: $0.b)
            }
    }
}
extension Mark.Block.Paragraph {
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        let env = env.withScope(block: .paragraph)
        let parser = IO.UnitParser
            .bounded(
                extract: Self.wholeChunk,
                execute: Mark.Inline.some(env: env)
            )
            .map(Mark.Block.Paragraph.init(content:))
        return parser
    }
    public static var wholeChunk: IO.TextParser {
        let body = IO.CharParser.pop
            .notFollowedBy(IO.TextParser.token("\n\n"))
            .some
            .map(IO.Text.init(from:))
        let rest = IO.CharParser
            .char { !$0.isNewline }
            .many
            .map(IO.Text.init(from:))
        return IO.Tuple
            .join(f: body, g: rest)
            .map { IO.Text(flatten: [$0.a, $0.b]) }
    }
}
extension Mark.Block.Blockquote {
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        let env = env.withScope(block: .blockquote)
        let terminator = IO.TextParser.token("\n\n")
        let lines = IO.UnitParser
            .lines(
                lineStart: Self.start,
                terminator: IO.ControlFlowParser.wrap(flip: terminator),
                trim: true
            )
        return lines
            .andThen { lines in
                IO.UnitParser.boundedFork(
                    text: lines.content,
                    execute: Mark.many(env: env)
                ).map {
                    Self(startDelimiters: lines.lineStarts, content: $0)
                }
            }
    }
    public static var start: IO.TextParser {
        return IO.TextParser
            .token(">")
            .ignore(next: IO.CharParser.space.optional)
    }
}
extension Mark.Block.FencedCodeBlock {
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        let token = IO.TextParser.token("```")
        return token
            .and2(
                f: IO.TextParser.restOfLine.optional,
                g: IO.CharParser
                    .pop
                    .manyTill(terminator: token)
                    .map {
                        $0.mapA(IO.Text.init(from:))
                    }
            )
            .map {
                Self(fenceStart: $0.a, infoString: $0.b, content: $0.c.a, fenceEnd: $0.c.b)
            }
    }
}
extension Mark.Block.HorizontalRule {
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        return IO.Parser
            .options([
                IO.TextParser.token("***").and(next: IO.CharParser.pop(char: "*").many),
                IO.TextParser.token("---").and(next: IO.CharParser.pop(char: "-").many),
                IO.TextParser.token("___").and(next: IO.CharParser.pop(char: "_").many)
            ])
            .map {
                IO.Text(from: $0.a.chars.with(append: $0.b))
            }
            .map(Self.init(tokens:))
    }
}
extension Mark.Block.List {
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        let env = env.withScope(block: .list)
        let p1 = Mark.Block.List.UnorderedItem
            .some(env: env)
            .map(Mark.Block.List.unordered(list:))
        let p2 = Mark.Block.List.OrderedItem
            .some(env: env)
            .map { Mark.Block.List.ordered(list: $0) }
        return IO.Parser.options([ p1, p2 ])
    }
}
extension Mark.Block.List.UnorderedItem {
    public static func some(env: Mark.Environment) -> IO.Parser<[Self]> {
        let env = env.withScope(block: .unorderedListItem)
        return Mark.Block.List.UnorderedItem
            .parser(env: env)
            .ignore(next: IO.CharParser.newline.many)
            .some
    }
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        let env = env.withScope(block: .unorderedListItem)
        let parser = Self.start.andThen { start in
            IO.UnitParser
                .bounded(
                    extract: IO.TextParser.wholeIndentedBlock(deindent: true),
                    execute: Mark.many(env: env)
                )
                .map { content in
                    Self(bullet: start, content: content)
                }
        }
        return parser
    }
    public static var start: IO.Parser<IO.Text.FatChar> {
        return IO.Parser
            .options([
                IO.CharParser.pop(char: "*"),
                IO.CharParser.pop(char: "-"),
                IO.CharParser.pop(char: "+"),
            ])
            .ignore(next: IO.CharParser.space.some).spacedLeft
    }
}
extension Mark.Block.List.OrderedItem {
    public static func some(env: Mark.Environment) -> IO.Parser<[Self]> {
        let env = env.withScope(block: .orderedListItem)
        return Mark.Block.List.OrderedItem
            .parser(env: env)
            .ignore(next: IO.CharParser.newline.many)
            .some
    }
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        let env = env.withScope(block: .orderedListItem)
        let parser = Self.start.andThen { start in
            IO.UnitParser
                .bounded(
                    extract: IO.TextParser.wholeIndentedBlock(deindent: true),
                    execute: Mark.many(env: env)
                )
                .map { content in
                    Self(number: start.a, dot: start.b, content: content)
                }
        }
        return parser
    }
    public static var start: IO.TupleParser<IO.Text, IO.Text.FatChar> {
        return IO.Tuple
            .join(
                f: IO.CharParser.number.some.map(IO.Text.init(from:)),
                g: IO.CharParser.char { $0 == "." }
            )
            .ignore(next: IO.CharParser.space.some)
            .spacedLeft
    }
}
extension Mark.Block.List.TaskItem {
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        let env = env.withScope(block: .taskListItem)
        let parser = Self.start.andThen { start in
            IO.UnitParser
                .bounded(
                    extract: IO.TextParser.wholeIndentedBlock(deindent: true),
                    execute: Mark.many(env: env)
                )
                .map { content in
                    Self(bullet: start.a, header: start.b, content: content)
                }
        }
        return parser
            .ignore(next: IO.CharParser.newline.many)
    }
    public static var start: IO.TupleParser<IO.Text.FatChar, Mark.Inline.InSquareBrackets<IO.Text?>> {
        let inner = IO.Parser.options([
            IO.CharParser.char { $0.lowercased() == "x" }.spaced,
        ])
        return IO.Tuple
            .join(
                f: IO.CharParser.pop(char: "-"),
                g: Mark.Inline.InSquareBrackets
                    .parser(content: inner.optional)
                    .map { $0.map({$0.map(IO.Text.init(singleton:))}) }
            )
            .ignore(next: IO.CharParser.space.some)
            .spacedLeft
    }
}
extension Mark.Block.Table {
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        let header = Mark.Block.Table.Header.parser(env: env)
        let body = Mark.Block.Table.Row.parser(env: env).many
        return IO.Tuple
            .join(f: header, g: body)
            .map {
                Self(header: $0.a, data: $0.b)
            }
    }
}
extension Mark.Block.Table.Header {
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        let header = Mark.Block.Table.Row.parser(env: env)
        let separator = Mark.Block.Table.SeperatorRow.parser(env: env)
        return IO.Tuple
            .join(f: header, g: separator)
            .map {
                Self(header: $0.a, separator: $0.b)
            }
    }
}
extension Mark.Block.Table.SeperatorRow {
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        let pipe = IO.CharParser.pop(char: "|")
        let colon = IO.CharParser.pop(char: ":")
        let dashes = IO.TextParser
            .token("---")
            .and(next: IO.CharParser.pop(char: "-").many)
            .map {
                $0.a.with(append: IO.Text.init(from: $0.b))
            }
            .spaced
        let seperator = IO.Triple
            .join(
                f: colon.optional,
                g: dashes,
                h: colon.optional
            )
            .spaced
            .and(next: pipe.optional)
            .map {
                Self.Cell(startColon: $0.a.a, dashes: $0.a.b, endColon: $0.a.c, endDelimiter: $0.b)
            }
        let parser = IO.UnitParser.bounded(
            extract: IO.TextParser.restOfLine.ignore(next: IO.CharParser.newline.optional),
            execute: pipe.optional.and(next: seperator.some).map { row in
                Self(
                    startDelimiter: row.a,
                    columns: row.b
                )
            }
        )
        return parser
    }
}
extension Mark.Block.Table.Row {
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        let pipe = IO.CharParser.pop(char: "|")
        let extractor = IO.TextParser.restOfLine.ignore(next: IO.CharParser.newline.optional)
        let row = pipe.optional
            .and(
                next: IO.CharParser
                    .char { $0 != "|" }
                    .manyUnless(terminator: pipe.spaced)
                    .map { $0.mapA(IO.Text.init(from:)) }
                    .map { $0.mapA {Mark.Inline.raw($0)} }
                    .map {
                        Self.Cell(content: [$0.a], pipeDelimiter: $0.b)
                    }
                    .some
            )
            .map {
                Self(startDelimiter: $0.a, cells: $0.b)
            }
        return IO.UnitParser
            .bounded(
                extract: extractor,
                execute: row
            )
    }
}
