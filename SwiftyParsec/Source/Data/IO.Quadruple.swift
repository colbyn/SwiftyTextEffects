//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/5/24.
//

import Foundation
import SwiftyDebug

extension IO {
    /// A generic structure for holding four related values of possibly different types.
    ///
    /// Extends the idea of `Tuple` and `Triple` for situations where four related items need to be passed or returned from a function as a single composite value.
    public struct Quadruple<A, B, C, D> {
        public let a: A
        public let b: B
        public let c: C
        public let d: D
        public init(a: A, b: B, c: C, d: D) {
            self.a = a
            self.b = b
            self.c = c
            self.d = d
        }
    }
    public typealias QuadrupleParser<A, B, C, D> = Parser<Quadruple<A, B, C, D>>
}

extension IO.Quadruple {
    public static func join(
        f a: @autoclosure @escaping () -> IO.Parser<A>,
        g b: @autoclosure @escaping () -> IO.Parser<B>,
        h c: @autoclosure @escaping () -> IO.Parser<C>,
        i d: @autoclosure @escaping () -> IO.Parser<D>
    ) -> IO.QuadrupleParser<A, B, C, D> {
        a().andThen { a in
            b().andThen { b in
                c().andThen { c in
                    d().andThen { d in
                        IO.Parser.pure(value: IO.Quadruple(a: a, b: b, c: c, d: d))
                    }
                }
            }
        }
    }
}

// MARK: - DEBUG -
extension IO.Quadruple: ToPrettyTree where A: ToPrettyTree, B: ToPrettyTree, C: ToPrettyTree, D: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(label: "Quadruple", children: [
            .init(key: "a", value: a.asPrettyTree),
            .init(key: "b", value: b.asPrettyTree),
            .init(key: "c", value: c.asPrettyTree),
            .init(key: "d", value: d.asPrettyTree),
        ])
    }
}
