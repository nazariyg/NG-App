// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public struct HTTPResponse<Payload> {

    public let payload: Payload
    public let headers: [HTTPHeader.Response: String]
    public let statusCode: HTTPStatusCode
    public let urlResponse: HTTPURLResponse
    public let request: HTTPRequest

    // MARK: - Lifecycle

    public init(
        payload: Payload,
        headers: [HTTPHeader.Response: String],
        urlResponse: HTTPURLResponse,
        request: HTTPRequest) {

        self.payload = payload
        self.headers = headers
        statusCode = HTTPStatusCode(urlResponse.statusCode)
        self.urlResponse = urlResponse
        self.request = request
    }

    /// The response's content type.
    public var contentType: HTTPContentType? {
        return headers[HTTPHeader.Response.contentType].flatMap { HTTPContentType(contentTypeString: $0) }
    }

}

public typealias HTTPDataResponse = HTTPResponse<Data>
