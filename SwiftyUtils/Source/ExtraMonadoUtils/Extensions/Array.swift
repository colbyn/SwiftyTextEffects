//
//  Array.swift
//  
//
//  Created by Colbyn Wadman on 3/29/24.
//

import Foundation

extension Array {
    public func with(append tail: Self) -> Self {
        var xs = self
        xs.append(contentsOf: tail)
        return xs
    }
    public func with(append element: Element) -> Self {
        var xs = self
        xs.append(element)
        return xs
    }
    public func uncons() -> (Element, Self)? {
        var copy = self
        if copy.isEmpty {
            return nil
        }
        let first = copy.removeFirst()
        return (first, copy)
    }
    public mutating func tryPopFirst() -> Element? {
        guard !self.isEmpty else { return nil }
        return removeFirst()
    }
    public mutating func tryPopLast() -> Element? {
        guard !self.isEmpty else { return nil }
        return removeLast()
    }
}

extension Array where Element: Sequence {
    public func flatten() -> [Element.Element] { self.flatMap { $0 } }
}
