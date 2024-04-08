//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/6/24.
//

import Foundation

// MARK: - BASICS -
extension IO.TextParser {
    /// Creates a parser that consumes a specific string pattern from the input.
    ///
    /// This parser matches and consumes the exact sequence of characters defined by the given pattern. It's particularly useful for recognizing specific keywords, symbols, or other fixed sequences within a larger text stream.
    ///
    /// - Parameter pattern: The exact string sequence to match and consume.
    /// - Returns: A parser that consumes the specified string pattern if it matches the beginning of the input.
    ///
    /// Example:
    /// ```swift
    /// let keywordParser = TapeParser.pop("func")
    /// // Consumes the keyword "func" from the input, if present.
    /// ```
    public static func token(_ pattern: String) -> Self {
        Self {
            guard let (head, rest) = $0.text.split(prefix: pattern) else {
                return $0.break()
            }
            return $0.set(text: rest).continue(value: head)
        }
    }
    /// A parser that consumes and returns any whitespace characters it encounters, except for newline characters.
    ///
    /// - Returns: A parser that consumes leading whitespace from the input and returns an `IO.Text` containing the consumed whitespace characters, up until a non-whitespace or newline character is encountered.
    ///
    public static var spaces: Self {
        IO.CharParser.char { $0.isWhitespace && !$0.isNewline }
            .many
            .map { IO.Text(from: $0) }
    }
    public static var anyWhitespace: Self {
        IO.CharParser.char { $0.isWhitespace }
            .many
            .map { IO.Text(from: $0) }
    }
    /// A parser that consumes and returns the remainder of the current line, stopping at a newline character or end of input.
    ///
    /// This parser is valuable for scenarios where you need to capture entire lines of text, such as parsing log files, reading configuration entries, or processing command output. It effectively grabs all characters up to, but not including, the next newline character.
    ///
    /// - Returns: A parser that consumes all characters up to the next newline or the end of the input.
    public static var restOfLine: Self {
        IO.CharParser.char { !$0.isNewline }.some.map(IO.Text.init(from:))
    }
    public func append(char: @escaping @autoclosure () -> IO.CharParser) -> IO.TextParser {
        self.and(next: char()).map { $0.a.with(append: $0.b) }
    }
    public func append(text: @escaping @autoclosure () -> IO.TextParser) -> IO.TextParser {
        self.and(next: text()).map { $0.a.with(append: $0.b) }
    }
    public func append(chars: @escaping @autoclosure () -> IO.Parser<[IO.Text.FatChar]>) -> IO.TextParser {
        self.and(next: chars()).map { $0.a.with(append: IO.Text(from: $0.b)) }
    }
}

// MARK: - EXTRA UTILS -
extension IO.TextParser {
    public static func wholeIndentedBlock(deindent: Bool) -> Self {
        let parser: (IO.Text.PositionIndex) -> IO.TextParser = { start in
            IO.CharParser
                .pop {
                    let check1 = $0.value.isWhitespace
                    let check2 = $0.index.column >= start.column
                    return (check1 || check2) // any whitespace or indented chars
                }
                .some
                .map(IO.Text.init(from:))
        }
        return Self {
            guard let (head, _) = $0.text.uncons else { return $0.continue(value: IO.Text.empty) }
            let f: (IO.Text) -> IO.Text = {
                $0.transformLines {
                    $0.filter {
                        $0.index.column >= head.index.column
                    }
                }
            }
            let g: (IO.Text) -> IO.TextParser = {
                let (leading, trailing) = $0.trimTrailing(includeNewlines: true).native
                return IO.UnitParser.unit
                    .set(pure: leading) // RETURN ALL TEXT NOT INCLUDING TRAILING WHITESPACE
                    .putBack(text: trailing) // PUT ANY TRAILING WHITESPACE BACK INTO THE UNPARSED STREAM
            }
            return parser(head.index).map(f).andThen(g).binder($0)
        }
    }
}
