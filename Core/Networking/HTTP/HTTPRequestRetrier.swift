// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Alamofire

public struct HTTPRequestRetrier {

    private static let retryingRequestsConfig = Config.shared.general.retryingFailedNetworkRequests

    private static func shouldRetryRequest(withRequest request: Request, error: CoreError, responseStatusCode: Int?) -> RetryResult {
        let doNotRetryResult: RetryResult = .doNotRetry
        let retryWithDelayResult: RetryResult = .retryWithDelay(Self.retryingRequestsConfig.retryingTimeDelay)
        let defaultResult = doNotRetryResult

        // Look at the HTTP method and do not retry if the method is not a safe one.
        if let methodString = request.request?.httpMethod,
           let method = HTTPRequestMethod(methodString: methodString),
           !method.isSafe {

            return doNotRetryResult
        }

        // In any case, only retry a limited number of times.
        if request.retryCount >= retryingRequestsConfig.maxRetryCount {
            return doNotRetryResult
        }

        if error == .networkTimedOut {
            // Don't prolong the user's waiting time.
            return doNotRetryResult
        }

        if error == .networkingError {
            return retryWithDelayResult
        }

        // The `responseStatusCode` logic may go here.

        return defaultResult
    }

}

extension HTTPRequestRetrier: Alamofire.RequestRetrier {

    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        let responseStatusCode = request.response?.statusCode
        let retryResult = Self.shouldRetryRequest(withRequest: request, error: CoreError(error), responseStatusCode: responseStatusCode)

        completion(retryResult)
    }

}
