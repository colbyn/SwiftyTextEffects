//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 3/2/24.
//

import SwiftUI

fileprivate struct ViewHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        let next = nextValue()
        if next > value {
            value = next
        }
    }
}

fileprivate struct ViewHeightPreferenceViewModifier: ViewModifier {
    let onChange: (CGFloat) -> ()
    func body(content: Content) -> some View {
        content
            .background(background)
            .onPreferenceChange(ViewHeightPreferenceKey.self, perform: onChange)
    }
    private var background: some View {
        GeometryReader { geo in
            Color.clear.preference(key: ViewHeightPreferenceKey.self, value: geo.size.height)
        }
    }
}

extension View {
    public func readHeight(onChange: @escaping (CGFloat) -> ()) -> some View {
        return modifier(ViewHeightPreferenceViewModifier(onChange: onChange))
    }
}
