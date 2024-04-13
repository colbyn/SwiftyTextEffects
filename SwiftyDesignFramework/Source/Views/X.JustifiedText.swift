//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 3/2/24.
//

import SwiftUI

//extension X {
//    /// For justified text
//    public struct JustifiedText {
//        let text: String
//        public init(_ text: String) {
//            self.text = text
//        }
//    }
//}
//
//extension X.JustifiedText: View {
//    public var body: some View {
//        TextViewRepresentable(text: text)
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//    }
//}
//
//// MARK: - ENVIRONMENT -
//
//// MARK: - INTERNAL -
//fileprivate struct TextViewRepresentable: UIViewRepresentable {
//    let text: String // Bind to a text variable
//    @Environment(\.xForegroundColor) private var xForegroundColor
//    @Environment(\.xFont) private var xFont
//
//    public func makeUIView(context: Context) -> CustomTextView {
//        CustomTextView.build(
//            text: text,
//            foregroundColor: xForegroundColor?.adaptiveColor,
//            font: xFont
//        )
//    }
//    
//    public func updateUIView(_ uiView: CustomTextView, context: Context) {}
//}
//
//
//fileprivate final class CustomTextView: UIView {
//    fileprivate var foregroundColor: X.Color?
//    fileprivate var font: LX.Font?
//    private let textStorage = NSTextStorage()
//    private let layoutManager = NSLayoutManager()
//    private let textContainer = NSTextContainer()
//    
//    static func build(text: String, foregroundColor: X.Color?, font: LX.Font?) -> Self {
//        let textView = Self()
//        textView.foregroundColor = foregroundColor
//        textView.font = font ?? LX.Font.systemFont(ofSize: 16, weight: .regular, width: .standard)
//        textView.commonInit(text: text)
//        return textView
//    }
//    
//    func commonInit(text: String) {
//        // Set up the relationship between the components
//        contentMode = .redraw
//        layoutManager.addTextContainer(textContainer)
//        textStorage.addLayoutManager(layoutManager)
//        
//        // Configure the textContainer
//        textContainer.lineFragmentPadding = 0
//        textContainer.maximumNumberOfLines = 0
//        textContainer.lineBreakMode = .byWordWrapping
//        textContainer.widthTracksTextView = true
//        
//        // Create a paragraph style with justified alignment
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.alignment = .justified
//        paragraphStyle.usesDefaultHyphenation = true
//        
//        // Add the text
//        let attributedText = NSAttributedString(
//            string: text,
//            attributes: [
//                .font: font ?? LX.Font.systemFont(ofSize: 18),
//                .paragraphStyle: paragraphStyle,
//                .foregroundColor: foregroundColor ?? X.ColorMap.default.adaptiveColor,
//            ]
//        )
//        textStorage.setAttributedString(attributedText)
//        
//        // Custom styling
//        backgroundColor = .clear
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        // Since the bounds of the view might change, we need to update the text container size.
//        textContainer.size = CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude)
//        
//        // Invalidate intrinsic content size so it can be recalculated with the new bounds.
//        invalidateIntrinsicContentSize()
//    }
//    
//    override func draw(_ rect: CGRect) {
//        let range = layoutManager.glyphRange(for: textContainer)
//        layoutManager.drawBackground(forGlyphRange: range, at: CGPoint.zero)
//        layoutManager.drawGlyphs(forGlyphRange: range, at: CGPoint.zero)
//    }
//    
//    override var intrinsicContentSize: CGSize {
//        // Force layout manager to perform layout calculations.
//        layoutManager.ensureLayout(for: textContainer)
//
//        // Calculate the bounding rectangle for the laid-out text.
//        let textBoundingBox = layoutManager.usedRect(for: textContainer)
//
//        // Return the calculated size as the intrinsic content size.
//        // Adding some padding for better visual appearance.
//        let padding: CGFloat = 16 // Adjust padding as needed.
//        return CGSize(width: UIView.noIntrinsicMetric, height: textBoundingBox.size.height + padding)
//    }
//    override func didMoveToSuperview() {
//        super.didMoveToSuperview()
//
//        setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
//        setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
//
//        setContentHuggingPriority(.defaultHigh, for: .horizontal)
//        setContentHuggingPriority(.defaultHigh, for: .vertical)
//    }
//    
//}
//
//
//
