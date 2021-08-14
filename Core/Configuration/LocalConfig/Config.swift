// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones

public enum ConfigEnvironment {
    case dev
    case prod
}

// MARK: - Protocol

public protocol ConfigProtocol {
    var environment: ConfigEnvironment { get }
    var general: GeneralConfig { get }
}

// MARK: - Implementation

public final class Config: ConfigProtocol, SharedInstance {

    public typealias InstanceProtocol = ConfigProtocol
    public static func defaultInstance() -> InstanceProtocol { return Config() }
    public static let doesReinstantiate = false

    // MARK: - Settings

    public let environment: ConfigEnvironment
    public let general: GeneralConfig

    // MARK: - Lifecycle

    private init() {
        switch UserDefinedBuildSettings.string["environment"] {
        case "Dev":
            environment = .dev
        case "Prod":
            environment = .prod
        default:
            assertionFailure()
            environment = .prod
        }

        general = .init()
    }

}
