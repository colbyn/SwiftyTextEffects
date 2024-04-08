//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/7/24.
//

import Foundation
import SwiftyParsec

extension Mark {
    public static func parser(env: Mark.Environment) -> IO.Parser<Self> {
        IO.Parser.options([
            Mark.Block.parser(env: env).map(Mark.block),
            Mark.Inline.parser(env: env).map(Mark.inline),
        ])
    }
    public static func many(env: Mark.Environment) -> IO.Parser<[Self]> {
        return Mark.parser(env: env).sequence(
            settings: .default.allowEmpty(true)
        )
    }
    public static func some(env: Mark.Environment) -> IO.Parser<[Self]> {
        return Mark.parser(env: env).sequence(
            settings: .default.allowEmpty(false)
        )
    }
}
