// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import RealmSwift

// MARK: - Internal

struct LocalStoreMigrations {

    // Current schema version.
    static let currentSchemaVersion = 0

    static let migrationSteps: [String: VoidClosure] = [
        "0 -> 1": { /* migration */ }
    ]

    static var migrationClosure: MigrationBlock {
        let migrationClosure: MigrationBlock = { (migration: Migration, oldSchemaVersion: UInt64) in
            guard currentSchemaVersion > oldSchemaVersion else { return }
            let stepKeys =
                (Int(oldSchemaVersion)..<currentSchemaVersion)
                .map { "\($0) -> \($0 + 1)" }
            stepKeys.forEach { key in migrationSteps[key]?() }
        }
        return migrationClosure
    }

}
