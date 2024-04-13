//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 3/3/24.
//

import SwiftUI

extension X {
    public struct Panel<Label: View, Content: View> {
        let label: () -> Label
        let content: () -> Label
    }
}

extension X.Panel: View {
    public var body: some View {
        Text("TODO")
    }
}
