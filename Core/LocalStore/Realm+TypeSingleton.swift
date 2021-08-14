// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import RealmSwift

public extension Realm {

    subscript<Model: RealmSwift.Object>(key: Model.Type) -> Model? {
        get {
            guard !(isMain && !LocalStore.shared.mainStoreIsInitialized.value) else { return nil }

            let existingObjects = objects(key)
            assert(existingObjects.count <= 1)
            return existingObjects.first
        }

        set(object) {
            guard !(isMain && !LocalStore.shared.mainStoreIsInitialized.value) else { return }

            // Relying on the fact that `key` is a singleton itself.
            synchronized(key) {
                if let object = object {
                    // Add or replace.
                    let existingObjects = objects(key)
                    modify {
                        var objectAlreadyExists = false
                        existingObjects.forEach { existingObject in
                            if !existingObject.isSameObject(as: object) {
                                delete(existingObject)
                            } else {
                                objectAlreadyExists = true
                            }
                        }
                        if !objectAlreadyExists {
                            add(object)
                        }
                    }
                } else {
                    // Delete.
                    let existingObjects = objects(key)
                    modify {
                        delete(existingObjects)
                    }
                }
            }
        }
    }

}
