//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 3/26/24.
//

import Foundation

extension Array {
    mutating func replaceExpand<C>(index: Self.Index, with newElements: C) where Element == C.Element, C : Collection {
        self.replaceSubrange(index...index, with: newElements)
    }
    func with(append newElement: Element) -> Self {
        var xs = self
        xs.append(newElement)
        return xs
    }
    func with(tail: [Element]) -> Self {
        var xs = self
        xs.append(contentsOf: tail)
        return xs
    }
    func firstMap<Result>(where f: (Self.Element) -> Result?) -> Result? {
        for element in self {
            if let result = f(element) {
                return result
            }
        }
        return nil
    }
}

extension Array {
    mutating func append(optional element: Optional<Self.Element>) {
        if let element = element {
            self.append(element)
        }
    }
}
