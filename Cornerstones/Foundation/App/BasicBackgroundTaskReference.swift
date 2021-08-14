// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import UIKit

public final class BasicBackgroundTaskReference {

    private var taskIdentifier: UIBackgroundTaskIdentifier = .invalid

    public static func begin() -> BasicBackgroundTaskReference {
        let reference = BasicBackgroundTaskReference()
        let taskIdentifier = UIApplication.shared.beginBackgroundTask(withName: nil, expirationHandler: { reference.end() })
        reference.taskIdentifier = taskIdentifier
        return reference
    }

    @discardableResult
    public func end() -> Bool {
        synchronized(self) {
            guard taskIdentifier != .invalid else { return false }
            UIApplication.shared.endBackgroundTask(taskIdentifier)
            taskIdentifier = .invalid
            return true
        }
    }

    private init() {}

    deinit {
        end()
    }

}
