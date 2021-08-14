// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public enum HTTPRequestMethod: String {

    case get
    case head
    case post
    case put
    case delete
    case trace
    case options
    case connect
    case patch

    public init?(methodString: String) {
        self.init(rawValue: methodString.lowercased())
    }

    /// The name of the method, uppercased.
    public var name: String {
        let name = rawValue.uppercased()
        return name
    }

    /// Returns whether the method may change the state of the server.
    public var isSafe: Bool {
        switch self {
        case .get, .head, .trace, .options:
            return true
        default:
            return false
        }
    }

    /// Returns whether multiple identical requests of this method should have the same effect as a single request thereof.
    public var isIdempotent: Bool {
        switch self {
        case .put, .delete:
            return true
        default:
            return false
        }
    }

}
