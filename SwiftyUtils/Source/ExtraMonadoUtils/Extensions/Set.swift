//
//  Set.swift
//  
//
//  Created by Colbyn Wadman on 3/29/24.
//

import Foundation

import Foundation

extension Set {
    public static func flatten(sets: [Self]) -> Self {
        Set(sets.flatMap { $0 })
    }
}
