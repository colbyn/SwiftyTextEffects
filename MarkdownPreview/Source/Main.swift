//
//  MarkdownPreviewApp.swift
//  MarkdownPreview
//
//  Created by Colbyn Wadman on 4/8/24.
//

import SwiftUI
import SwiftyMarkUI

@main
struct Main: App {
    var body: some Scene {
        WindowGroup {
            VStack(alignment: .center, spacing: 0) {
                ScrollView(.vertical) {
                    MarkUI.Display(
                        fromSource: """
                        *Italic text* or _Italic text_ **Bold text** or __Bold text__ ~~Strikethrough text~~ You can also use plain HTML in your Markdown, and it should be left unchanged. ![Placeholder Image](https://via.placeholder.com/150) Inline `code` snippet. [Headers](#headers) [Emphasis](#emphasis) [Lists](#lists) [Links and Images](#links-and-images) [Code Blocks and Syntax Highlighting](#code-blocks-and-syntax-highlighting) [Tables](#tables) [Block-quotes](#block-quotes) [Horizontal Rules](#horizontal-rules) [Task Lists](#task-lists) [GitHub](https://github.com) ![Placeholder Image](https://via.placeholder.com/150) This is **bold** text embedded within a sentence. This is *italic* text embedded within normal text. This text is **bold, _italic_, and** normal. Here is some `inline code` mixed with text. Visit [OpenAI](https://www.openai.com) for more information. This is ~~strikethrough~~ text. Text with an inline image ![Alt Text](https://example.com/image.png) here. Markdown uses \\*characters\\* that might need to be escaped. Text with *asterisks* and_text with underscores_. This is **bold and [part of a link](https://example.com)**. In Markdown, you can combine **bold**, *italic*, `code`, ~~strikethrough~~, and even [links](https://www.example.com) all in one sentence! Check out this link: [Example Link](https://example.com/this?that=everything&more=1). This is a reference style link [with a reference][ref]. [ref]: https://example.com Display backticks in inline code like this: `Here is a \\`backtick\\` inside code`. Nested **bold *italic `code`* end bold**.
                        """)
                        .padding(10)
                }
            }
        }
    }
}
