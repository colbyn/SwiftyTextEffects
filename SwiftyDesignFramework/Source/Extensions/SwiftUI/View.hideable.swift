//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 3/2/24.
//

import SwiftUI

extension View {
    @ViewBuilder public func hideable(hidden: Bool?, remove: Bool = true) -> some View {
        if hidden == true {
            if remove {
                EmptyView()
            } else {
                self.hidden()
            }
        } else {
            self
        }
    }
    @ViewBuilder public func hideable(visible: Bool?, remove: Bool = true) -> some View {
        if visible == true {
            self
        } else if remove {
            EmptyView()
        } else {
            self.hidden()
        }
    }
}


