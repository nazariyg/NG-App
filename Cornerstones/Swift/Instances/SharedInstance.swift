// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

/// The protocol to be adopted by any class with a shared instance.
/// Any conforming class must typealias `InstanceProtocol` to its interface protocol.
public protocol SharedInstance {
    associatedtype InstanceProtocol
    static var doesReinstantiate: Bool { get }
    static func defaultInstance() -> InstanceProtocol
}

public extension SharedInstance {

    static func instantiate() {
        InstanceService.shared.registerOrGetSharedInstanceForNormalExecution(for: self, isResettable: doesReinstantiate)
    }

    /// In normal execution, asks the `InstanceService` for the currently registered shared instance and returns it or, during tests,
    /// returns the currently injected shared instance.
    static var shared: InstanceProtocol {
        if TestingDetector.isNormalExecution {
            // Normal execution.
            return InstanceService.shared.registerOrGetSharedInstanceForNormalExecution(for: self, isResettable: doesReinstantiate)
        } else {
            // Testing.
            return InstanceService.shared.instance(for: InstanceProtocol.self, defaultInstance: defaultInstance())
        }
    }

}
