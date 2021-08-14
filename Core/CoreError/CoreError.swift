// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public enum CoreError: String, Swift.Error, CaseIterable {

    // Networking.
    case networkingError
    case networkTimedOut
    case serverError
    case notAuthenticated
    case networkResponseNotFound
    case httpErrorCode
    case unexpectedHTTPResponseContentType
    case unexpectedHTTPResponsePayload

    case unknown

}
