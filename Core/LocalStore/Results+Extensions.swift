// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import RealmSwift

public extension RealmSwift.Results {

    func materialize() -> [Element] {
        return Array(self)
    }

}
