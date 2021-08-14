// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import RealmSwift

open class LocalStoreEntity: RealmSwift.Object {

    public required convenience init(copying other: LocalStoreEntity) {
        self.init(value: other)
    }

    /// Returns a copy that is not thread-confined and is free to be passed across threads and queues.
    public func readOnlyCopy() -> Self {
        return Self(copying: self)
    }

}
