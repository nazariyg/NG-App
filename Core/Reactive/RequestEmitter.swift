// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones

/// It's sufficient for conforming classes to just contain a nested `Request` type, without explicit typealiasing.
/// The interface protocol of a conforming class should declare `var requests: O<ClassName.Request> { get }` in order to
/// open `requests` for access and circumvent the constraints of using a protocol with an associated type.
public protocol RequestEmitter: StoredProperties {
    associatedtype Request
}

private struct StoredPropertyKeys {
    static let requestStreamIsInitialized = "requestStreamIsInitialized"
    static let emitter = "requestEmitter"
    static let requests = "requests"
}

public extension RequestEmitter {

    var requestEmitter: S<Request> {
        return requestStream.emitter
    }

    var requests: O<Request> {
        return requestStream.requests
    }

    private var requestStream: (emitter: S<Request>, requests: O<Request>) {
        return synchronized(self) {
            if let isInitialized = sp.bool[StoredPropertyKeys.requestStreamIsInitialized], isInitialized {
                let emitter = sp.any[StoredPropertyKeys.emitter] as! S<Request>
                let requests = sp.any[StoredPropertyKeys.requests] as! O<Request>
                return (emitter, requests)
            } else {
                let emitter = S<Request>()
                let requests = emitter.asObservable()
                sp.any[StoredPropertyKeys.emitter] = emitter
                sp.any[StoredPropertyKeys.requests] = requests
                sp.bool[StoredPropertyKeys.requestStreamIsInitialized] = true
                return (emitter, requests)
            }
        }
    }

}
