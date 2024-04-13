//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 3/31/24.
//

import Foundation
import SwiftUI

extension X {
    public struct TabGroups {}
}

extension X.TabGroups {
    public struct Tab {
        let label: AnyView
        let content: AnyView
    }
    public struct Builder {
        let tabs: Tab
    }
}

extension X.TabGroups: View {
    public var body: some View {
        Text("TODO")
    }
}
