//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/5/24.
//

import Foundation
import SwiftyDebug

extension IO {
    /// A generic structure for holding two related values of possibly different types.
    ///
    /// The `Tuple` type is useful for functions that need to return more than one value, encapsulating them in a single composite value.
    public struct Tuple<A, B> {
        public let a: A
        public let b: B
        public init(_ a: A, _ b: B) {
            self.a = a
            self.b = b
        }
    }
    public typealias TupleParser<A, B> = Parser<Tuple<A, B>>
}

extension IO.Tuple {
    public func mapA<T>(_ f: @escaping (A) -> T) -> IO.Tuple<T, B> {
        IO.Tuple<T, B>(f(a), b)
    }
    public func mapB<T>(_ f: @escaping (B) -> T) -> IO.Tuple<A, T> {
        IO.Tuple<A, T>(a, f(b))
    }
    public static func join(
        f: @autoclosure @escaping () -> IO.Parser<A>,
        g: @autoclosure @escaping () -> IO.Parser<B>
    ) -> IO.TupleParser<A, B> {
        f().andThen { a in
            g().andThen { b in
                IO.Parser.pure(value: Self(a, b))
            }
        }
    }
    public var native: (A, B) {
        (self.a, self.b)
    }
}

// MARK: - DEBUG -
extension IO.Tuple: ToPrettyTree where A: ToPrettyTree, B: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(label: "Tuple", children: [
            .init(key: "a", value: a.asPrettyTree),
            .init(key: "b", value: b.asPrettyTree),
        ])
    }
}
