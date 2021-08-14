// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones

/// It's sufficient for conforming classes to just contain a nested `Event` type, without explicit typealiasing.
/// The interface protocol of a conforming class should declare `var events: O<ClassName.Event> { get }` in order to
/// open `events` for access and circumvent the constraints of using a protocol with an associated type.
public protocol EventEmitter: StoredProperties {
    associatedtype Event
}

private struct StoredPropertyKeys {
    static let eventStreamIsInitialized = "eventStreamIsInitialized"
    static let emitter = "eventEmitter"
    static let events = "events"
}

public extension EventEmitter {

    var eventEmitter: S<Event> {
        return eventStream.emitter
    }

    var events: O<Event> {
        return eventStream.events
    }

    private var eventStream: (emitter: S<Event>, events: O<Event>) {
        return synchronized(self) {
            if let isInitialized = sp.bool[StoredPropertyKeys.eventStreamIsInitialized], isInitialized {
                let emitter = sp.any[StoredPropertyKeys.emitter] as! S<Event>
                let events = sp.any[StoredPropertyKeys.events] as! O<Event>
                return (emitter, events)
            } else {
                let emitter = S<Event>()
                let events = emitter.asObservable()
                sp.any[StoredPropertyKeys.emitter] = emitter
                sp.any[StoredPropertyKeys.events] = events
                sp.bool[StoredPropertyKeys.eventStreamIsInitialized] = true
                return (emitter, events)
            }
        }
    }

}
