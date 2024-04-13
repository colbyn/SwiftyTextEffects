//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/8/24.
//

import Foundation
import SwiftUI

import SwiftyMarkAST
import SwiftyDesignFramework


extension MarkUI {
    public struct Display {
        let markdown: [Mark]
        public init(fromSource source: String) {
            print("PARSING: ...")
            let start = Date.now
            self.markdown = Mark.parse(source: source)
            let end = Date.now
            let timeInterval = end.timeIntervalSince(start)
            print("PARSING: DONE")
            print("Execution Time: \(timeInterval) seconds")
            print(self.markdown.asPrettyTree.format())
        }
    }
}

extension MarkUI.Display: View {
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            MarkdownNodeList(nodes: markdown)
        }
    }
}

// MARK: - GENERAL -
fileprivate struct MarkdownNodeList: View {
    let nodes: [(Mark, UUID)]
    init(nodes: [(Mark, UUID)]) {
        self.nodes = nodes
    }
    init(nodes: [Mark]) {
        self.nodes = nodes.map { ($0, UUID()) }
    }
    var body: some View {
        ForEach(nodes, id: \.1) { (node, _) in
            MarkdownNode(node: node)
        }
    }
}

fileprivate struct MarkdownNode: View {
    let node: Mark
    var body: some View {
        switch node {
        case .inline(let inline):
            InlineView(nodes: [inline])
        case .block(let block):
            BlockView(node: block)
        }
    }
}

// MARK: - INLINE VIEW -
fileprivate struct InlineView: View {
    let nodes: [ Mark.Inline ]
    var body: some View {
        if !sourceString.isEmpty {
            if let attributedString = attributedString {
                Text(attributedString)
                    .textSelection(.enabled)
            } else {
                Text(sourceString)
                    .textSelection(.enabled)
            }
        }
    }
    var sourceString: String {
        nodes
            .map { $0.stringify }.joined(separator: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: " ")
    }
    var attributedString: AttributedString? {
        return try? AttributedString(
            markdown: sourceString,
            options: .init(
                allowsExtendedAttributes: true,
                interpretedSyntax: .inlineOnly,
                failurePolicy: .returnPartiallyParsedIfPossible
            )
        )
    }
}

// MARK: - BLOCK VIEW -
fileprivate struct BlockView {
    let node: Mark.Block
}

extension BlockView {
    struct Heading {
        let node: Mark.Block.Heading
    }
    struct Paragraph {
        let node: Mark.Block.Paragraph
    }
    struct Blockquote {
        let node: Mark.Block.Blockquote
    }
    struct List {
        let node: Mark.Block.List
    }
    struct FencedCodeBlock {
        let node: Mark.Block.FencedCodeBlock
        @Environment(\.colorScheme) private var colorScheme
    }
    struct HorizontalRule {
        let node: Mark.Block.HorizontalRule
    }
    struct Table {
        let node: Mark.Block.Table
    }
}

extension BlockView: View {
    var body: some View {
        switch node {
        case .heading(let heading):
            Self.Heading(node: heading)
        case .paragraph(let paragraph):
            Self.Paragraph(node: paragraph)
        case .blockquote(let blockquote):
            Self.Blockquote(node: blockquote)
        case .list(let list):
            Self.List(node: list)
        case .fencedCodeBlock(let fencedCodeBlock):
            Self.FencedCodeBlock(node: fencedCodeBlock)
        case .horizontalRule(let horizontalRule):
            Self.HorizontalRule(node: horizontalRule)
        case .table(let table):
            Self.Table(node: table)
        case .newline:
            EmptyView()
        }
    }
}

extension BlockView.Heading: View {
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            InlineView(nodes: node.content)
                .font(font)
            Spacer()
        }
        .outline(.bottom, color: Self.lineColor, lineWidth: 0.5, show: level == .h1)
    }
    var level: Mark.Block.Heading.Level? {
        node.level
    }
    var font: Font {
        switch level {
        case .h1: return .system(size: 40, weight: .bold)
        case .h2: return .system(size: 35, weight: .semibold)
        case .h3: return .system(size: 30, weight: .semibold)
        case .h4: return .system(size: 25, weight: .medium)
        case .h5: return .system(size: 20, weight: .regular)
        case .h6: return .system(size: 18, weight: .light)
        default: return .body
        }
    }
    static var lineColor: X.ColorMap {
        X.ColorMap(
            light: {#colorLiteral(red: 0.7996326711, green: 0.7969798516, blue: 0.828134992, alpha: 1)},
            dark: {#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)}
        )
    }
}
extension BlockView.Paragraph: View {
    var body: some View {
        InlineView(nodes: node.content)
            .font(.body)
            .padding([.leading, .trailing], 10)
    }
}
extension BlockView.Blockquote: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            MarkdownNodeList(nodes: node.content)
                .xForegroundColor(Self.foregroundColor)
        }
        .padding(.leading, 10)
        .outline(.leading, color: BlockView.Blockquote.lineColor, lineWidth: 5.0)
        .padding(.leading, 20)
    }
    static var lineColor: X.ColorMap {
        X.ColorMap(
            light: {#colorLiteral(red: 0.9084009369, green: 0.9012837691, blue: 0.9620199936, alpha: 0.802980544)},
            dark: {#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)}
        )
    }
    static var foregroundColor: X.ColorMap {
        X.ColorMap(
            light: {#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)},
            dark: {#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)}
        )
    }
}
extension BlockView.FencedCodeBlock: View {
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(node.content.asString.trimmingCharacters(in: .whitespacesAndNewlines))
            Spacer()
        }
        .font(.system(size: 18, weight: .regular, design: .monospaced))
        .padding(10)
        .background(backgroundView)
        .padding([.leading, .trailing], 20)
    }
    @ViewBuilder private var backgroundView: some View {
        let bgColor = Self.backgroundColor.apply(colorScheme: colorScheme).asSUIColor
        ZStack {
            RoundedRectangle(cornerRadius: 3.0)
                .foregroundColor(bgColor)
            RoundedRectangle(cornerRadius: 3.0)
                .stroke(lineWidth: 0.5)
                .xForegroundColor(Self.strokeColor)
        }
    }
    static var backgroundColor: X.ColorMap {
        X.ColorMap(
            light: {#colorLiteral(red: 0.9806823793, green: 0.9436152524, blue: 0.9760442477, alpha: 0.2003208863)},
            dark: {#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)}
        )
    }
    static var strokeColor: X.ColorMap {
        X.ColorMap(
            light: {#colorLiteral(red: 0.4847001662, green: 0.4275140691, blue: 0.6725973424, alpha: 1)},
            dark: {#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)}
        )
    }
}
extension BlockView.HorizontalRule: View {
    var body: some View {
        Divider()
    }
}

extension BlockView.List: View {
    var body: some View {
        Text("TODO: BlockView.List")
    }
}
extension BlockView.Table: View {
    var body: some View {
        Text("TODO: BlockView.Table")
    }
}
