//
//  String.swift
//  
//
//  Created by Colbyn Wadman on 3/29/24.
//

import Foundation

extension String {
    public enum TruncationPosition {
        case head, middle, tail
    }
}

extension String {
    public func truncated(limit: Int, position: TruncationPosition, leader: String = "…") -> String {
        // If the current string length is within the limit, return the string itself
        guard self.count > limit else { return self }

        // Ensure that the limit is always positive after adjusting for the leader's length
        let effectiveLimit = max(0, limit - leader.count)

        switch position {
        case .head:
            // For the head, we take the last part of the string after the leader
            let tailLength = min(effectiveLimit, self.count)
            return "\(leader)\(self.suffix(tailLength))"
        case .middle:
            // For the middle, we split the limit (adjusted for leader length) between the start and end
            let halfLimit = effectiveLimit / 2
            let headLength = halfLimit
            // Adjust the tail length in case of an odd effectiveLimit
            let tailLength = effectiveLimit - headLength
            return "\(self.prefix(headLength))\(leader)\(self.suffix(tailLength))"
        case .tail:
            // For the tail, we simply take the prefix of the string before adding the leader
            let headLength = min(effectiveLimit, self.count)
            return "\(self.prefix(headLength))\(leader)"
        }
    }
}


