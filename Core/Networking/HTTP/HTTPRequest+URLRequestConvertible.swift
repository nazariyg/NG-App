// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Alamofire

extension HTTPRequest {

    public func asURLRequest(usingSession session: Session) -> URLRequest {
        let afMethod = method.afMethod

        var afParameters: Parameters?
        if let parameters = parameters {
            afParameters = parameters.keyValues
        }

        var afParameterEncoding: ParameterEncoding = URLEncoding.default
        if let parameters = parameters {
            switch parameters.placement {
            case .urlQueryString:
                afParameterEncoding = URLEncoding.queryString
            case let .body(encoding):
                switch encoding {
                case .url:
                    afParameterEncoding = URLEncoding.httpBody
                case .json:
                    afParameterEncoding = JSONEncoding.default
                }
            case .auto:
                assertionFailure()
            }
        }

        var afHeaders: HTTPHeaders?
        if headers._isNotEmpty {
            let headersDictionary: [String: String] = .init(uniqueKeysWithValues: headers.map({ key, value in (key.rawValue, value) }))
            afHeaders = HTTPHeaders(headersDictionary)
        }

        // Let Alamofire do the job of parameter encoding, setting headers, etc.
        let afRequest =
            session.request(
                url,
                method: afMethod,
                parameters: afParameters,
                encoding: afParameterEncoding,
                headers: afHeaders)

        var urlRequest: URLRequest!
        do {
            urlRequest = try afRequest.convertible.asURLRequest()
        } catch {
            let errorMessage = "Error converting `AFRequest` to `URLRequest`: \(error)"
            assertionFailure(errorMessage)
            return URLRequest(url: URL(string: "https://oops.com")!)
        }

        if let cachePolicy = cachePolicy {
            urlRequest.cachePolicy = cachePolicy
        }

        if let timeoutInterval = timeoutInterval {
            urlRequest.timeoutInterval = timeoutInterval
        }

        return urlRequest
    }

}

private extension HTTPRequestMethod {

    var afMethod: HTTPMethod {
        switch self {
        case .get: return .get
        case .head: return .head
        case .post: return .post
        case .put: return .put
        case .delete: return .delete
        case .trace: return .trace
        case .options: return .options
        case .connect: return .connect
        case .patch: return .patch
        }
    }

}
