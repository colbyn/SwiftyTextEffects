//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/6/24.
//

import Foundation

extension IO {
    public struct Lines<Prefix, Content> {
        /// The startings tokens of each line.
        public let lineStarts: [Prefix]
        /// The parsed sub-content.
        public let content: Content
    }
}
