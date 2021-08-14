// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public struct TestingDetector {

    private static let testingFlagEnvironmentVariableName = "XCTestConfigurationFilePath"

    static var isTesting: Bool = {
        return ProcessInfo.processInfo.environment[testingFlagEnvironmentVariableName] != nil
    }()

    static var isNormalExecution: Bool = {
        return !isTesting
    }()

}
