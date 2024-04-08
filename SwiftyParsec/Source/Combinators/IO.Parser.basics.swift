//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/5/24.
//
// This file contains Monado’s core monadic parser combinators.

import Foundation

extension IO.Parser {
    /// Disregards the current value.
    public var void: IO.UnitParser {
        IO.UnitParser {
            switch self.binder($0) {
            case .continue(value: _, state: let rest):
                return rest.continue(value: IO.unit)
            case .break(state: let out): return out.break()
            }
        }
    }
    /// Attempts to parse using each parser in the provided array, in order, stopping at the first success.
    ///
    /// - Parameter parsers: An array of parsers to be tried sequentially until one succeeds.
    /// - Returns: A parser that succeeds if any of the provided parsers succeed.
    public static func options(_ parsers: @escaping @autoclosure () -> [Self]) -> Self {
        return Self {
            loop: for p in parsers() {
                switch p.binder($0) {
                case .continue(value: let a, state: let state): return state.continue(value: a)
                case .break: continue loop
                }
            }
            return $0.break()
        }
    }
    /// Creates a parser that sequences this parser with another, discarding the result of this parser and only returning the result of the second.
    ///
    /// This combinator is useful when the result of the first parser is not needed, but its successful execution is required to proceed. It's a common pattern for skipping over delimiters or other syntax elements where only the content following these elements is of interest.
    ///
    /// - Parameter right: A parser to be executed after the current parser, whose result will be returned.
    /// - Returns: A parser that returns the result of the second parser if both parsers succeed; otherwise, it fails with the state of the first failure encountered.
    public func keep<B>(next f: @escaping @autoclosure () -> IO.Parser<B>) -> IO.Parser<B> {
        andThen { _ in f() }
    }
    /// Creates a parser that ignores the result of another parser applied after the current parser.
    ///
    /// - Parameter right: The parser whose result is to be ignored.
    /// - Returns: A parser that returns the result of the first parser while ignoring the result of the second.
    public func ignore<B>(next f: @escaping @autoclosure () -> IO.Parser<B>) -> IO.Parser<A> {
        andThen { a in f().set(pure: a) }
    }
    /// Attempts to parse using the current parser, then applies another parser on the remaining input and combines their results.
    ///
    /// - Parameter next: A function that returns a parser to be applied after the current one.
    /// - Returns: A parser that sequences the application of two parsers and combines their results into a tuple.
    public func and<B>(next: @escaping @autoclosure () -> IO.Parser<B>) -> IO.TupleParser<A, B> {
        IO.Tuple.join(f: self, g: next())
    }
    /// Combines the current parser with two additional parsers, sequencing their execution and aggregating their results into a triple.
    ///
    /// - Parameters:
    ///   - f: The second parser to be executed.
    ///   - g: The third parser to be executed.
    /// - Returns: A parser that combines the results of all three parsers into a triple.
    public func and2<B, C>(
        f: @escaping @autoclosure () -> IO.Parser<B>,
        g: @escaping @autoclosure () -> IO.Parser<C>
    ) -> IO.TripleParser<A, B, C> {
        IO.Triple.join(f: self, g: f(), h: g())
    }
    public func and3<B, C, D>(
        f: @escaping @autoclosure () -> IO.Parser<B>,
        g: @escaping @autoclosure () -> IO.Parser<C>,
        h: @escaping @autoclosure () -> IO.Parser<D>
    ) -> IO.QuadrupleParser<A, B, C, D> {
        IO.Quadruple.join(f: self, g: f(), h: g(), i: h())
    }
    /// Creates a parser that results in an `Either` type, encapsulating the result of the first successful parser.
    ///
    /// - Parameter other: A parser to attempt if the first parser fails.
    /// - Returns: A parser that encapsulates the result of the first successful parser in an `Either` type.1
    public func either<B>(or: @escaping @autoclosure () -> IO.Parser<B>) -> IO.EitherParser<A, B> {
        IO.Either.try(left: self, right: or())
    }
    public func or(`try`: @escaping @autoclosure () -> IO.Parser<A>) -> IO.Parser<A> {
        IO.Either.try(left: self, right: `try`()).map(IO.Either.unwrap(value:))
    }
    /// Marks the parser as optional, allowing it to succeed with a `nil` value if the underlying parser fails.
    ///
    /// - Returns: A parser that succeeds with an optional value.
    public var optional: IO.Parser<A?> {
        IO.Parser<A?> {
            let (a, state) = self.binder($0).unwrap
            return state.continue(value: a)
        }
    }
    /// Encloses the parser within leading and trailing terminators, returning the parsed value flanked by the terminators' results.
    ///
    /// - Parameter bothEnds: A parser that matches both the leading and trailing delimiters.
    /// - Returns: A parser that captures the leading delimiter, the main content, and the trailing delimiter as a triple.
    public func between<B>(bothEnds terminator: IO.Parser<B>) -> IO.TripleParser<B, A, B> {
        return terminator.andThen { x in
            self.andThen { y in
                terminator.map { z in
                    IO.Triple(x, y, z)
                }
            }
        }
    }
    /// Encloses the parser between distinct leading and trailing parsers, useful for structures with different start and end markers.
    ///
    /// This function is particularly handy for parsing constructs like HTML tags, where the opening and closing syntax differ, but you're interested in capturing the content within, along with the delimiters.
    ///
    /// - Parameters:
    ///   - leading: A parser that matches the opening delimiter.
    ///   - trailing: A parser that matches the closing delimiter.
    /// - Returns: A parser that returns a triple: the result of the leading delimiter, the main content, and the result of the trailing delimiter.
    public func between<B, C>(
        leading: @escaping @autoclosure () -> IO.Parser<B>,
        trailing: @escaping @autoclosure () -> IO.Parser<C>
    ) -> IO.TripleParser<B, A, C> {
        return leading().andThen { x in
            self.andThen { y in
                trailing().map { z in
                    IO.Triple(x, y, z)
                }
            }
        }
    }
    public func putBack(text: IO.Text?) -> Self {
        if let text = text {
            return Self {
                let input = $0.set(text: IO.Text(flatten: [text, $0.text]))
                switch self.binder(input) {
                case .continue(value: let a, state: let state): return state.continue(value: a)
                case .break(state: let state): return state.break()
                }
            }
        }
        return self
    }
    public func putBack(char: IO.Text.FatChar?) -> Self {
        return self.putBack(text: char.map {.cons($0, .empty)})
    }
    /// Creates a parser that ignores trailing whitespace after parsing the value.
    ///
    /// - Returns: A parser that ignores trailing whitespace.
    public var spacedRight: IO.Parser<A> {
        self.ignore(next: IO.TextParser.spaces.optional)
    }
    /// Creates a parser that ignores leading whitespace before parsing the value.
    ///
    /// - Returns: A parser that ignores leading whitespace.
    public var spacedLeft: IO.Parser<A> {
        IO.TextParser.spaces.optional.keep(next: self)
    }
    /// Creates a parser that ignores both leading and trailing whitespace around the parsed value.
    ///
    /// - Returns: A parser that ignores surrounding whitespace.
    public var spaced: IO.Parser<A> {
        IO.TextParser.spaces.optional.keep(next: self).ignore(next: IO.TextParser.spaces.optional)
    }
    public func notFollowedBy<B>(_ parser: @autoclosure @escaping () -> IO.Parser<B>) -> IO.Parser<A> {
        IO.Parser<A> {
            switch self.binder($0) {
            case .continue(value: let a, state: let state):
                if case .break = parser().binder(state) {
                    return state.continue(value: a)
                }
                return state.break()
            case .break(state: let state): return state.break()
            }
        }
    }
    public func deactivate(if flag: Bool) -> Self {
        if flag {
            return Self.break
        }
        return self
    }
}

