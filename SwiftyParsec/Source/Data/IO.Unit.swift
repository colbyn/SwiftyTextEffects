//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/5/24.
//

import Foundation
import SwiftyDebug

extension IO {
    public struct Unit {
        internal init() {}
        public static let unit: Self = Unit()
    }
    public typealias UnitParser = Parser<Unit>
}

// MARK: - DEBUG -
extension IO.Unit: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree.value("Unit")
    }
}
