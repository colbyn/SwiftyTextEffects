//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/5/24.
//

import Foundation

extension IO {
    public struct Parser<A> {
        internal let binder: (State) -> Output
        /// Initializes a parser with a binding function, which defines how the parser processes input and produces output.
        internal init(binder: @escaping (State) -> Output) {
            self.binder = binder
        }
        internal enum Output {
            case `continue`(value: A, state: State)
            case `break`(state: State)
        }
    }
}

extension IO.Parser.Output {
    public var unwrap: (A?, IO.State) {
        switch self {
        case .continue(let value, let state): return (value, state)
        case .break(let state): return (nil, state)
        }
    }
}

//extension IO.Parser.Output {
//    public static 
//}

extension IO.Parser {
    /// Creates a parser that always succeeds with the given value, without consuming any input.
    ///
    /// - Parameter value: The value that the parser will return upon evaluation.
    /// - Returns: A parser that always returns the provided value.
    public static func pure(value: A) -> Self {
        Self { $0.continue(value: value) }
    }
    /// Creates a parser that always fails.
    ///
    /// - Returns: A parser that always fails without consuming any input.
    public static var fail: Self {
        Self { $0.break() }
    }
    public static var `break`: Self {
        Self { $0.break() }
    }
    /// Sequences two parsers, running the second parser after the first and combining their results.
    ///
    /// - Parameter f: A function that takes the result of the first parser and returns the second parser to execute.
    /// - Returns: A parser that combines the results of two parsers.
    ///
    /// Example:
    /// ```swift
    /// let combinedParser = Parser<String>.token("Hello").andThen { _ in Parser<String>.token("World") }
    /// ```
    public func andThen<B>(_ f: @escaping (A) -> IO.Parser<B>) -> IO.Parser<B> {
        IO.Parser<B> {
            switch self.binder($0) {
            case .continue(value: let a, state: let o):
                switch f(a).binder(o) {
                case .continue(value: let b, state: let o):
                    return o.continue(value: b)
                case .break(state: let o):
                    return o.break()
                }
            case .break(state: let o):
                return o.break()
            }
        }
    }
    /// Transforms the result of the parser with a given function.
    ///
    /// - Parameter f: A function to apply to the result of the parser.
    /// - Returns: A parser that transforms its result with the given function.
    public func map<B>(_ f: @escaping (A) -> B) -> IO.Parser<B> {
        andThen {
            IO.Parser<B>.pure(value: f($0))
        }
    }
    /// Creates a parser that consumes no input and always returns the provided value.
    ///
    /// - Parameter pure value: The value to be returned by the parser.
    /// - Returns: A parser that always succeeds with the given value.
    public func set<T>(pure value: T) -> IO.Parser<T> {
        map { _ in value }
    }
}

extension IO.Parser {
    /// Evaluates the parser against a given source string, producing either a parsed value or nil if parsing fails, along with the final parser state.
    ///
    /// - Parameters:
    ///   - source: The input string to be parsed.
    /// - Returns: A tuple containing the optional parsed value and the final state of the parser.
    ///
    /// Example:
    /// ```swift
    /// let parser = Parser<Int>.pure(value: 42)
    /// let result = parser.evaluate(source: "input string")
    /// print(result) // Prints "(Optional(42), ParserState(...))"
    /// ```
    public func evaluate(source: String) -> (A?, IO.State) {
        let state = IO.State(text: IO.Text(initalize: source))
        switch self.binder(state) {
        case .continue(value: let a, state: let state): return (a, state)
        case .break(state: let state): return (nil, state)
        }
    }
}
