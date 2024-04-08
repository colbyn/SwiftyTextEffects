//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/5/24.
//

import Foundation
import SwiftyDebug

extension IO {
    /// The `Either` type represents a value of one of two possible types (a disjoint union). Instances of `Either` are either an instance of `Left` or `Right`.
    ///
    /// `Either` is useful for cases where a function might return two different types of objects. It's a way to carry information about a success or an error, where `Left` might represent a failure and `Right` a success.
    public enum Either<Left, Right> {
        case left(Left), right(Right)
    }
    public typealias EitherParser<Left, Right> = Parser<Either<Left, Right>>
}

extension IO.Either {
    /// Determines whether the instance is a `Left` value.
    public var isLeft: Bool {
        switch self {
        case .left(_): return true
        case .right(_): return false
        }
    }
    /// Determines whether the instance is a `Right` value.
    public var isRight: Bool {
        switch self {
        case .right(_): return true
        case .left(_): return false
        }
    }
    /// Returns the contained `Left` value, if present; otherwise, `nil`.
    public var asLeft: Left? {
        switch self {
        case .left(let x): return x
        case .right(_): return nil
        }
    }
    /// Returns the contained `Right` value, if present; otherwise, `nil`.
    public var asRight: Right? {
        switch self {
        case .right(let x): return x
        case .left(_): return nil
        }
    }
    public static func `try`(
        left: @escaping @autoclosure () -> IO.Parser<Left>,
        right: @escaping @autoclosure () -> IO.Parser<Right>
    ) -> IO.EitherParser<Left, Right> {
        IO.EitherParser<Left, Right> {
            if case .continue(value: let left, state: let state) = left().binder($0) {
                return state.continue(value: IO.Either.left(left))
            }
            if case .continue(value: let right, state: let state) = right().binder($0) {
                return state.continue(value: IO.Either.right(right))
            }
            return $0.break()
        }
    }
}

extension IO.Either where Left == Right {
    public var into: Left {
        switch self {
        case .left(let left): return left
        case .right(let right): return right
        }
    }
    public static func unwrap(value: IO.Either<Left, Right>) -> Left {
        switch value {
        case .left(let left): return left
        case .right(let right): return right
        }
    }
}

// MARK: - DEBUG -
extension IO.Either: ToPrettyTree where Left: ToPrettyTree, Right: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        switch self {
        case .left(let left): return PrettyTree(key: "Either.left", value: left.asPrettyTree)
        case .right(let right): return PrettyTree(key: "Either.right", value: right.asPrettyTree)
        }
    }
}
