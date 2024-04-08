//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/5/24.
//

import Foundation
import SwiftyDebug

extension IO {
    /// A generic structure for holding three related values of possibly different types.
    ///
    /// Similar to `Tuple`, but for cases where three values need to be grouped together. Useful for returning multiple values from a function and maintaining type information.
    public struct Triple<A, B, C> {
        public let a: A
        public let b: B
        public let c: C
        public init(_ a: A, _ b: B, _ c: C) {
            self.a = a
            self.b = b
            self.c = c
        }
    }
    public typealias TripleParser<A, B, C> = Parser<Triple<A, B, C>>
}

extension IO.Triple {
    /// Returns a new `Triple` with the first value transformed by the given function.
    public func mapA<T>(_ f: @escaping (A) -> T) -> IO.Triple<T, B, C> {
        IO.Triple<T, B, C>(f(a), b, c)
    }
    /// Returns a new `Triple` with the second value transformed by the given function.
    public func mapB<T>(_ f: @escaping (B) -> T) -> IO.Triple<A, T, C> {
        IO.Triple<A, T, C>(a, f(b), c)
    }
    /// Returns a new `Triple` with the third value transformed by the given function.
    public func mapC<T>(_ f: @escaping (C) -> T) -> IO.Triple<A, B, T> {
        IO.Triple<A, B, T>(a, b, f(c))
    }
    public static func join(
        f a: @autoclosure @escaping () -> IO.Parser<A>,
        g b: @autoclosure @escaping () -> IO.Parser<B>,
        h c: @autoclosure @escaping () -> IO.Parser<C>
    ) -> IO.TripleParser<A, B, C> {
        a().andThen { a in
            b().andThen { b in
                c().andThen { c in
                    IO.Parser.pure(value: IO.Triple(a, b, c))
                }
            }
        }
    }
}

// MARK: - DEBUG -
extension IO.Triple: ToPrettyTree where A: ToPrettyTree, B: ToPrettyTree, C: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(label: "Triple", children: [
            .init(key: "a", value: a.asPrettyTree),
            .init(key: "b", value: b.asPrettyTree),
            .init(key: "c", value: c.asPrettyTree),
        ])
    }
}
