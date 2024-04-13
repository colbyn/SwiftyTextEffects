//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 3/2/24.
//

import SwiftUI

fileprivate let DEFAULT_BORDER_COLOR = X.ColorMap(
    light: #colorLiteral(red: 0.419248732, green: 0.4514986308, blue: 0.4966484888, alpha: 1),
    dark: #colorLiteral(red: 0.227343088, green: 0.2854696492, blue: 0.3668468348, alpha: 1)
)
fileprivate let DEFAULT_LINE_WIDTH: CGFloat = 0.5

fileprivate struct ViewBorderModifier: ViewModifier {
    let edges: Edge.Set
    var borderColor: X.ColorMap?
    var lineWidth: CGFloat?
    func body(content: Content) -> some View {
        let color = (borderColor ?? DEFAULT_BORDER_COLOR).apply(colorScheme: colorScheme).asSUIColor
        let lineWidth = lineWidth ?? DEFAULT_LINE_WIDTH
        let border = EdgeBorderShape(width: lineWidth, edges: edges).foregroundColor(color)
        if !edges.isEmpty {
            content.overlay(border)
        } else {
            content
        }
    }
    private struct EdgeBorderShape: Shape {
        var width: CGFloat
        var edges: Edge.Set
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            var edgeList: Array<Edge> = []
            if edges.contains(.top) {
                edgeList.append(.top)
            }
            if edges.contains(.leading) {
                edgeList.append(.leading)
            }
            if edges.contains(.bottom) {
                edgeList.append(.bottom)
            }
            if edges.contains(.trailing) {
                edgeList.append(.trailing)
            }
            for edge in edgeList {
                var x: CGFloat {
                    switch edge {
                    case .top, .bottom, .leading: return rect.minX
                    case .trailing: return rect.maxX - width
                    }
                }
                var y: CGFloat {
                    switch edge {
                    case .top, .leading, .trailing: return rect.minY
                    case .bottom: return rect.maxY - width
                    }
                }
                var w: CGFloat {
                    switch edge {
                    case .top, .bottom: return rect.width
                    case .leading, .trailing: return self.width
                    }
                }
                var h: CGFloat {
                    switch edge {
                    case .top, .bottom: return self.width
                    case .leading, .trailing: return rect.height
                    }
                }
                path.addPath(Path(CGRect(x: x, y: y, width: w, height: h)))
            }
            return path
        }
    }
//    private var targetLineWidth: CGFloat {
//        if let lineWidth = borderLineWidthOverride {
//            return lineWidth
//        }
//        if let lineWidth = borderLineWidth {
//            return lineWidth
//        }
//        return UX.Env.Border.LineWidth.DEFAULT
//    }
//    private var targetBorderColor: Color {
//        if let borderColor = borderColorOverride {
//            return borderColor.apply(colorScheme: colorScheme).asColor
//        }
//        if let borderColor = borderColorMap {
//            return borderColor.apply(colorScheme: colorScheme).asColor
//        }
//        return UX.Env.Border.Color.DEFAULT.apply(colorScheme: colorScheme).asColor
//    }
//    @Environment(\.borderColorMap) private var borderColorMap
//    @Environment(\.borderLineWidth) private var borderLineWidth
    @Environment(\.colorScheme) private var colorScheme
}


extension View {
    public func outline(_ edges: Edge.Set, color: X.ColorMap? = nil, lineWidth: CGFloat? = nil, show: Bool = true) -> some View {
        modifier(ViewBorderModifier(
            edges: show ? edges : [],
            borderColor: color,
            lineWidth: lineWidth
        ))
    }
}



