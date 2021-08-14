// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones

public func initializeModule() {
    DispatchQueue.syncSafeOnMain {
        UIRootContainer.instantiate()
        UIScener.instantiate()
    }
}
