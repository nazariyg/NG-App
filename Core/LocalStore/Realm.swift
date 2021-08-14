// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Cornerstones
import RealmSwift

// MARK: - Public

public extension Realm {

    func modify(_ modificationClosure: ThrowingVoidClosure) rethrows {
        do {
            try write {
                try modificationClosure()
            }
        } catch {
            let message = "Error while trying to modify a store: \(error)"
            fatalError(message)
        }
    }

    func deleteAll(type: RealmSwift.Object.Type) {
        delete(objects(type))
    }

}

// MARK: - Internal

extension Realm {

    func enableBackgroundAccess() {
        let directoryPath = configuration.fileURL!.deletingLastPathComponent().path
        let attributes = [FileAttributeKey.protectionKey: FileProtectionType.none]
        do {
            try FileManager.default.setAttributes(attributes, ofItemAtPath: directoryPath)
        } catch {
            assertionFailure()
        }
    }

    var isMain: Bool {
        guard let filePath = configuration.fileURL?.absoluteString else {
            assertionFailure()
            return false
        }
        return filePath.contains(substring: LocalStore._mainStoreFileNamePrefix)
    }

}
