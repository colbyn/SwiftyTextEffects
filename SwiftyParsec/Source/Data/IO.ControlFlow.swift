//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 4/5/24.
//

import Foundation
import SwiftyDebug

extension IO {
    public enum ControlFlow {
        case noop
        case terminate
    }
    public typealias ControlFlowParser = Parser<ControlFlow>
}

extension IO.ControlFlow {
    public var isNoop: Bool {
        switch self {
        case .noop: return true
        default: return false
        }
    }
    public var isTerminate: Bool {
        switch self {
        case .terminate: return true
        default: return false
        }
    }
}

extension IO.ControlFlowParser {
    public static let noop: Self = IO.ControlFlowParser.pure(value: .noop)
    public static func wrap<T>(flip parser: @escaping @autoclosure () -> IO.Parser<T>) -> Self {
        Self {
            switch parser().binder($0) {
            case .continue: return $0.continue(value: .terminate)
            case .break: return $0.continue(value: .noop)
            }
        }
    }
}

// MARK: - DEBUG -
extension IO.ControlFlow: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        switch self {
        case .noop: return .value("ControlFlow.continue")
        case .terminate: return .value("ControlFlow.break")
        }
    }
}
