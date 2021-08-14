// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public extension CoreError {

    // MARK: - Lifecycle

    /// Constructs an error from a generic error or another core error.
    init(_ error: Swift.Error) {
        if let coreError = error as? CoreError {
            self = coreError
            return
        }

        let urlErrors = Self.allUnderlyingNSErrors(withDomain: NSURLErrorDomain, startingWithError: error)

        let isRootedInNetworkTimedOutError =
            urlErrors.contains(where: { urlError in
                return urlError.code == NSURLErrorTimedOut
            })

        var isRootedInNetworkError =
            urlErrors.contains(where: { urlError in
                switch urlError.code {

                case NSURLErrorCannotConnectToHost,
                     NSURLErrorCannotFindHost,
                     NSURLErrorDNSLookupFailed,
                     NSURLErrorNetworkConnectionLost,
                     NSURLErrorNotConnectedToInternet,
                     NSURLErrorTimedOut:

                    // This is a networking error.
                    return true

                default:
                    return false

                }
            })

        if !isRootedInNetworkError && error.asAFError?.isSessionTaskError == true {
            isRootedInNetworkError = true
        }

        if isRootedInNetworkTimedOutError {
            self = .networkTimedOut
        } else if isRootedInNetworkError {
            self = .networkingError
        } else {
            self = .unknown
        }
    }

    // MARK: - Private

    private static func allUnderlyingNSErrors(withDomain domain: String, startingWithError error: Error) -> [NSError] {
        var nsErrors: [NSError] = []
        var currentError = error
        while true {
            let nsError = currentError as NSError
            if nsError.domain == domain {
                nsErrors.append(nsError)
            }
            if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? Error {
                currentError = underlyingError
            } else {
                break
            }
        }
        return nsErrors
    }

}
