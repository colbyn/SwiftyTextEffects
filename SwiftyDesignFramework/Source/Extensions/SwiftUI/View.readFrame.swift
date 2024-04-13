//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 3/2/24.
//

import SwiftUI

// MARK: - PUBLIC API -
extension View {
    public func readFrame(coordinateSpace: CoordinateSpace, onChange: @escaping (CGRect) -> ()) -> some View {
        modifier(RectPreferenceViewModifier(coordinateSpace: coordinateSpace, onChange: onChange))
    }
    public func readFrame(onChange: @escaping (CGSize) -> ()) -> some View {
        modifier(SizePreferenceViewModifier(onChange: onChange))
    }
}


// MARK: - READ SIZE -
fileprivate struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
//        print("reduce")
    }
}
fileprivate struct SizePreferenceViewModifier: ViewModifier {
    let onChange: (CGSize) -> ()
    func body(content: Content) -> some View {
        content
            .background(background)
            .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
    private var background: some View {
        GeometryReader { geo in
            Color.clear.preference(key: SizePreferenceKey.self, value: geo.size)
        }
    }
}


// MARK: - READ RECT -
fileprivate struct RectPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = CGRect.zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}
fileprivate struct RectPreferenceViewModifier: ViewModifier {
    let coordinateSpace: CoordinateSpace
    let onChange: (CGRect) -> ()
    func body(content: Content) -> some View {
        content
            .background(background)
            .onPreferenceChange(RectPreferenceKey.self, perform: onChange)
    }
    private var background: some View {
        GeometryReader { geo in
            Color.clear.preference(key: RectPreferenceKey.self, value: geo.frame(in: coordinateSpace))
        }
    }
}

