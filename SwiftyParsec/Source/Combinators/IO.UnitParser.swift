//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/6/24.
//

import Foundation

extension IO.UnitParser {
    public static let unit = IO.UnitParser.pure(value: .unit)
}

extension IO.UnitParser {
    public static func lines(
        lineStart: @escaping @autoclosure () -> IO.TextParser,
        terminator: @escaping @autoclosure () -> IO.ControlFlowParser = IO.ControlFlowParser.noop,
        trim: Bool = true
    ) -> IO.Parser<IO.Lines<IO.Text, IO.Text>> {
        let parser = IO.Parser<IO.Lines<IO.Text, IO.Text>> {
            var current = $0
            var results: [IO.Text.FatChar] = []
            var lineGuard: IO.Text.PositionIndex? = nil
            var terminate = false
            var lineStarts: [IO.Text] = []
            // - -
            let remainingLine = IO.TextParser.restOfLine.optional.and(next: IO.CharParser.newline.optional).map {
                return IO.Text.init(
                    from: ($0.a?.chars ?? []).with(append: $0.b.map{[$0]} ?? [])
                )
            }
            // - -
            loop: while !current.text.isEmpty && !terminate {
                if case .continue(value: .terminate, state: let rest) = terminator().binder(current) {
                    return rest.continue(
                        value: IO.Lines(lineStarts: lineStarts, content: IO.Text(from: results))
                    )
                }
                // - -
                switch lineStart().and(next: remainingLine).binder(current) {
                case .continue(value: let output, state: let rest):
                    let leading = output.a.chars
                    let trailing = output.b.chars
                    let line = leading.with(append: trailing)
                    // - -
                    if leading.isEmpty {
                        break loop
                    }
                    // - -
                    if let lineGuard = lineGuard, let last = leading.last {
                        let isValid = last.index.column == lineGuard.column
                        terminate = !isValid
                    } else {
                        lineGuard = leading.last?.index
                    }
                    // - -
                    if !terminate {
                        results.append(contentsOf: trim ? trailing : line)
                        lineStarts.append(output.a)
                        current = rest
                    }
                case .break: break loop
                }
            }
            // - -
            if results.isEmpty {
                return $0.break()
            }
            // - -
            return current.continue(
                value: IO.Lines(lineStarts: lineStarts, content: IO.Text(from: results))
            )
        }
        let cleanup: (IO.Text) -> IO.TextParser = {
            let (leading, trailing) = $0.trimTrailing(includeNewlines: true).native
            return IO.UnitParser.unit
                .set(pure: leading) // RETURN ALL TEXT NOT INCLUDING TRAILING WHITESPACE
                .putBack(text: trailing) // PUT ANY TRAILING WHITESPACE BACK INTO THE UNPARSED STREAM
        }
        return parser.andThen {
            let lineStarts = $0.lineStarts
            return cleanup($0.content).map {
                return IO.Lines(lineStarts: lineStarts, content: $0)
            }
        }
    }
    public static func bounded<T>(
        extract extractor: @escaping @autoclosure () -> IO.TextParser,
        execute subparser: @escaping @autoclosure () -> IO.Parser<T>
    ) -> IO.Parser<T> {
        IO.Parser<T> {
            guard case .continue(value: let leading, state: let trailing) = extractor().binder($0) else {
                return $0.break()
            }
            let forkedState = trailing.set(text: leading)
            guard case .continue(value: let value, state: let rest) = subparser().binder(forkedState) else {
                return $0.break()
            }
            // FIND ORIGINAL STATE from `rest`
            let unparsed1 = $0.text
                .splitAt(
                    whereTrue: {
                        $0.index.character == rest.text.chars.first?.index.character
                    }
                )
                .map {
                    $0.b
                }
            let unparsed2 = unparsed1 ?? rest.text.with(append: trailing.text)
            return rest
                // Instead of returning a joined `Text` from `rest` + `trailing` we instead
                // use `rest` to find the original characters where `rest` starts from.
                .set(text: unparsed2)
                .continue(value: value)
        }
    }
    public static func boundedFork<T>(
        text: IO.Text,
        execute subparser: @escaping @autoclosure () -> IO.Parser<T>
    ) -> IO.Parser<T> {
        IO.Parser<T> {
            let forkedState = $0.set(text: text)
            guard case .continue(value: let value, state: let rest) = subparser().binder(forkedState) else {
                return $0.break()
            }
            // FIND ORIGINAL STATE from `rest`
            let unparsed1 = $0.text
                .splitAt(
                    whereTrue: {
                        $0.index.character == rest.text.chars.first?.index.character
                    }
                )
                .map {
                    $0.b
                }
            let unparsed2 = (unparsed1 ?? IO.Text(from: [])).with(append: $0.text)
            return rest
                // Instead of returning a joined `Text` from `rest` + `trailing` we instead
                // use `rest` to find the original characters where `rest` starts from.
                .set(text: unparsed2)
                .continue(value: value)
        }
    }
}
