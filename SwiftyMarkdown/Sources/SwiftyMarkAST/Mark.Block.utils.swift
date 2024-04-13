//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/8/24.
//

import Foundation

extension Mark.Block.Heading {
    public var level: Level? {
        let hashes = self.hashTokens.asString
        if hashes.count == 1 {
            return Level.h1
        }
        if hashes.count == 2 {
            return Level.h2
        }
        if hashes.count == 3 {
            return Level.h3
        }
        if hashes.count == 4 {
            return Level.h4
        }
        if hashes.count == 5 {
            return Level.h5
        }
        if hashes.count == 6 {
            return Level.h6
        }
        return nil
    }
    public enum Level: Equatable {
        case h1, h2, h3, h4, h5, h6
    }
}
