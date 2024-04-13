//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 3/2/24.
//

import SwiftUI

extension Binding {
    public static func proxy(_ source: Binding<Value>) -> Binding<Value> {
        self.init(
            get: { source.wrappedValue },
            set: { source.wrappedValue = $0 }
        )
    }
    public static func forceProxy(_ source: Binding<Value?>) -> Binding<Value> {
        self.init(
            get: {
                assert(source.wrappedValue != nil)
                return source.wrappedValue!
            },
            set: {
                source.wrappedValue = $0
            }
        )
    }
    public static func asOptional(_ source: Binding<Value>) -> Binding<Value?> {
        return Binding<Value?>(
            get: {
                let result: Value = source.wrappedValue
                return result
            },
            set: { newValue in
                if let newValue = newValue {
                    source.wrappedValue = newValue
                }
            }
        )
    }
}

