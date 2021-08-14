// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public struct HTTPRequestParameters {

    public enum Placement {

        /// Choose the placement automatically based on the HTTP method of the request.
        case auto

        /// Put the parameters into the query string of the request's URL.
        case urlQueryString

        /// Put the parameters into the body of the request.
        case body(encoding: BodyEncoding)
    }

    public enum BodyEncoding {

        /// Same encoding as used by query strings.
        case url

        /// JSON encoding.
        case json
    }

    public var placement: Placement
    public private(set) var keyValues: [String: Any]

    public init(_ keyValues: [String: Any] = [:], placement: Placement = .auto) {
        self.keyValues = keyValues
        self.placement = placement
    }

    public subscript(key: String) -> Any? {
        get {
            return keyValues[key]
        }

        set(value) {
            if let value = value {
                keyValues[key] = value
            } else {
                keyValues.removeValue(forKey: key)
            }
        }
    }

}
