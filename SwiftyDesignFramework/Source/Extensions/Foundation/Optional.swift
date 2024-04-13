//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 3/2/24.
//

import Foundation

extension Optional {
    public var isNone: Bool {
        switch self {
        case .none: return true
        case .some(_): return false
        }
    }
    public var isSome: Bool {
        switch self {
        case .none: return false
        case .some(_): return true
        }
    }
    public func unwrap(or: @autoclosure () -> Wrapped) -> Wrapped {
        if let this = self {
            return this
        }
        return or()
    }
    public func map<T>(f: @escaping (Wrapped) -> T) -> Optional<T> {
        if let this = self {
            return .some(f(this))
        }
        return .none
    }
}

extension Optional where Wrapped: Collection {
    public var isNilOrEmpty: Bool {
        if self == nil {
            return true
        }
        return self?.isEmpty == true
    }
}

