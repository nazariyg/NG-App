// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones

func initializeModule() {
    DispatchQueue.syncSafeOnMain {
        UIGlobalSceneRouter.instantiate()
    }
}
