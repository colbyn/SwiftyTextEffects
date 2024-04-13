//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 3/2/24.
//

import SwiftUI

//extension X {
//    public struct CardGalleryBuilder {
//        var items: [ (UUID, AnyView) ] = []
//        public init() {
//            self.items = []
//        }
//        public func view<Content: View>(content: @escaping () -> Content) -> Self {
//            var copy = CardGalleryBuilder()
//            copy.items = self.items.with(append: (UUID(), AnyView(content())))
//            return copy
//        }
//        public func build() -> X.CardGallery {
//            X.CardGallery(items: items)
//        }
//    }
//    public struct CardGallery {
//        var items: [ (UUID, AnyView) ]
//        @State private var minHeight: CGFloat = 100
//    }
//}
//
//extension X.CardGallery: View {
//    public var body: some View {
//        TabView(content: wrapper)
////            .tabViewStyle(.page)
//            .frame(minHeight: minHeight)
//    }
//    @ViewBuilder private func wrapper() -> some View {
//        ForEach(items, id: \.0) { (_, item) in
//            item
//                .padding(EdgeInsets(top: 10, leading: 10, bottom: 15, trailing: 10))
//                .readFrame {
//                    minHeight = max(minHeight, $0.height)
//                }
//        }
//    }
//}
