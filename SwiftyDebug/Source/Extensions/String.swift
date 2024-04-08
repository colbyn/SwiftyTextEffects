//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 3/26/24.
//

import Foundation

//extension String {
//    internal func truncate(limit: Int) -> String {
//        if self.count > limit {
//            let trimmed = self.prefix(limit)
//            if trimmed.starts(with: "\"") {
//                return "\(trimmed)\"…"
//            }
//            return String("\(trimmed)…")
//        }
//        return self
//    }
//}
//
//extension String {
//    internal enum TruncationPosition {
//        case head
//        case middle
//        case tail
//    }
//}
//
//extension String {
//    internal func truncated(limit: Int, position: TruncationPosition = .tail, leader: String = "…") -> String {
//        // If the current string length is within the limit, return the string itself
//        guard self.count > limit else { return self }
//
//        // Ensure that the limit is always positive after adjusting for the leader's length
//        let effectiveLimit = max(0, limit - leader.count)
//
//        switch position {
//        case .head:
//            // For the head, we take the last part of the string after the leader
//            let tailLength = min(effectiveLimit, self.count)
//            return "\(leader)\(self.suffix(tailLength))"
//        case .middle:
//            // For the middle, we split the limit (adjusted for leader length) between the start and end
//            let halfLimit = effectiveLimit / 2
//            let headLength = halfLimit
//            // Adjust the tail length in case of an odd effectiveLimit
//            let tailLength = effectiveLimit - headLength
//            return "\(self.prefix(headLength))\(leader)\(self.suffix(tailLength))"
//        case .tail:
//            // For the tail, we simply take the prefix of the string before adding the leader
//            let headLength = min(effectiveLimit, self.count)
//            return "\(self.prefix(headLength))\(leader)"
//        }
//    }
//}
//
//
