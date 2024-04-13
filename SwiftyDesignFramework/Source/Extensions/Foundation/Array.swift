//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 3/2/24.
//

import Foundation

extension Array {
    public func with(append: Element) -> Self {
        var copy = self
        copy.append(append)
        return copy
    }
}
