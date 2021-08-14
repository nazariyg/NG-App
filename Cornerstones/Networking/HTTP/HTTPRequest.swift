// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public struct HTTPRequest {

    public let url: URL
    public let authentication: HTTPRequestAuthentication?
    public let method: HTTPRequestMethod
    public let parameters: HTTPRequestParameters?
    public private(set) var headers: [HTTPHeader.Request: String]
    public let bodyData: Data?
    public let cachePolicy: HTTPRequestCachePolicy?
    public let timeoutInterval: TimeInterval?
    public let hasSensitiveData: Bool?

    /// Constructs an HTTP request.
    public init(
        url: URL,
        authentication: HTTPRequestAuthentication? = nil,
        method: HTTPRequestMethod = .get,
        parameters: HTTPRequestParameters? = nil,
        headers: [HTTPHeader.Request: String] = [:],
        bodyData: Data? = nil,
        cachePolicy: HTTPRequestCachePolicy? = nil,
        timeoutInterval: TimeInterval? = nil,
        hasSensitiveData: Bool? = nil) {

        var useParameters: HTTPRequestParameters!
        if let parameters = parameters, parameters.keyValues._isNotEmpty {
            useParameters = parameters
            if case .auto = useParameters.placement {
                let hasBody = bodyData != nil
                useParameters.placement = Self.autoParametersPlacement(forMethod: method, hasBody: hasBody)
            }

            // Check if the parameters's placement gets along with the request's body.
            let validateParametersPlacement = { () -> Bool in
                let hasBody = bodyData != nil
                if !hasBody {
                    // The parameters can be placed anywhere.
                    return true
                }
                // Has a body.
                var parametersAreInBody = false
                if case .body = useParameters.placement {
                    parametersAreInBody = true
                }
                return !parametersAreInBody
            }
            assert(validateParametersPlacement(), "Conflicting parameters placement")

            if case .body = useParameters.placement {
                assert(!method.isSafe, "Safe HTTP methods e.g. GET should not have parameters placed into the body")
            }
        }

        self.url = url
        self.authentication = authentication
        self.method = method
        self.parameters = useParameters
        self.headers = headers
        self.bodyData = bodyData
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeoutInterval
        self.hasSensitiveData = hasSensitiveData
    }

    /// The expected content type of a response to this request (the value of the "Accept" request header).
    public var expectedContentType: HTTPContentType? {
        get {
            return headers[HTTPHeader.Request.accept].flatMap { HTTPContentType(contentTypeString: $0) }
        }

        set(contentType) {
            if let contentType = contentType {
                headers[HTTPHeader.Request.accept] = contentType.string
            } else {
                headers.removeValue(forKey: HTTPHeader.Request.accept)
            }
        }
    }

    /// Adds provided headers **keeping** values for any existing header names.
    public mutating func includeHeaders(_ otherHeaders: [HTTPHeader.Request: String]) {
        headers.mergeKeeping(dictionary: otherHeaders)
    }

    // MARK: - Private

    private static func autoParametersPlacement(forMethod method: HTTPRequestMethod, hasBody: Bool) -> HTTPRequestParameters.Placement {
        if hasBody {
            return .urlQueryString
        }

        switch method {
        case .get, .head, .delete:
            return .urlQueryString
        case .post, .put, .trace, .options, .connect, .patch:
            return .body(encoding: .url)
        }
    }

}

extension HTTPRequest {

    public func description(logParameters: Bool) -> String {
        var components: [String] = []
        components.append(method.name)
        components.append(url.absoluteString)
        var description = components.joined(separator: " ")
        if logParameters, let parameters = parameters {
            description += "\nParameters:\n\(parameters.keyValues.prettyPrinted)"
        }
        return description
    }

    public var safeDescription: String {
        var components: [String] = []
        components.append(method.name)
        components.append(url.absoluteString)
        let description = components.joined(separator: " ")
        return description
    }

}
