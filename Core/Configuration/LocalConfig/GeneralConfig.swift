// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import CoreLocation

// All environments.
public class GeneralConfig {

    public let splashScreenDisplayMinTime: TimeInterval = 1

    // Local store.
    public let deletePersistentStoreIfMigrationNeeded = true

    // Networking.
    public let wrapEveryDataNetworkRequestIntoBackgroundTask = true
    public let requestTimeout: TimeInterval = 30
    public let responseResourceTimeout: TimeInterval = 3600
    public let retryingFailedNetworkRequests =
        RetryingFailedNetworkRequestsConfig(
            shouldRetry: false,
            maxRetryCount: 2,
            retryingTimeDelay: 1)
    public let acknowledgeServerErrors = true
    public let acknowledgeHTTPResponseNotFoundErrors = true
    public let acknowledgeHTTPResponseErrorCodes = true
    public let httpRequestSendUserAgentHeader = false
    public let httpRequestSendAcceptLanguageHeader = false
    public let logHTTPRequestParameters = true
    public let logHTTPResponseData = false
    public let maxHTTPResponseDataSizeForLogging = 1024
    public let curlPrintHTTPRequests = false
    public let suppressNetworkingErrorNotificationsWhileOffline = false

    // Background queues.
    public let defaultBackgroundQueueQoS: DispatchQoS = .default
    public let uiRelatedBackgroundQueueQoS: DispatchQoS = .userInteractive
    public let viperWorkerQueueQoS: DispatchQoS = .userInitiated

}

// MARK: - RetryingFailedNetworkRequestsConfig

public struct RetryingFailedNetworkRequestsConfig {
    public let shouldRetry: Bool
    public let maxRetryCount: Int
    public let retryingTimeDelay: TimeInterval
}
