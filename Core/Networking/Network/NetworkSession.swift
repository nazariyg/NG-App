// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Alamofire
import RxSwift

// MARK: - Protocol

public protocol NetworkSessionProtocol {
    var stateless: Reactive<Session> { get }
    var statefulCacheless: Reactive<Session> { get }
    var stateful: Reactive<Session> { get }
}

// MARK: - Implementation

/// Request dispatchers are represented by `URLSession` instances with reactive extensions.
public final class NetworkSession: NetworkSessionProtocol, SharedInstance {

    public typealias InstanceProtocol = NetworkSessionProtocol
    public static func defaultInstance() -> InstanceProtocol { return NetworkSession() }
    public static let doesReinstantiate = true

    // MARK: - Lifecycle

    private init() {}

    // MARK: - Session types

    /// Does not use cache and does not permanently store any cookies or credentials to disk.
    public let stateless: Reactive<Session> = {
        return NetworkSession.makeStateless()
    }()

    /// Does not use cache but permanently stores cookies and credentials.
    public let statefulCacheless: Reactive<Session> = {
        return NetworkSession.makeStatefulCacheless()
    }()

    /// Does use cache and permanently stores cookies and credentials.
    public let stateful: Reactive<Session> = {
        return NetworkSession.makeStateful()
    }()

    // MARK: - Factory

    /// Does not use cache and does not permanently store any cookies or credentials to disk.
    private static func makeStateless(baseConfiguration: URLSessionConfiguration? = nil) -> Reactive<Session> {
        let configuration: URLSessionConfiguration
        if let baseConfiguration = baseConfiguration {
            configuration = baseConfiguration
        } else {
            configuration = URLSessionConfiguration.ephemeral

            // Copy headers from the default configuration.
            configuration.httpAdditionalHeaders = defaultBaseConfiguration.httpAdditionalHeaders
        }

        // Disable caching completely.
        configuration.disableCaching()

        // Timeouts.
        configuration.timeoutIntervalForRequest = Config.shared.general.requestTimeout
        configuration.timeoutIntervalForResource = Config.shared.general.responseResourceTimeout

        let session = defaultSession(withConfiguration: configuration)
        return Reactive(session)
    }

    /// Does not use cache but permanently stores cookies and credentials.
    private static func makeStatefulCacheless(baseConfiguration: URLSessionConfiguration? = nil) -> Reactive<Session> {
        let configuration: URLSessionConfiguration
        if let baseConfiguration = baseConfiguration {
            configuration = baseConfiguration
        } else {
            configuration = defaultBaseConfiguration
        }

        // Disable caching completely.
        configuration.disableCaching()

        let session = defaultSession(withConfiguration: configuration)
        return Reactive(session)
    }

    /// Does use cache and permanently stores cookies and credentials.
    private static func makeStateful(baseConfiguration: URLSessionConfiguration? = nil) -> Reactive<Session> {
        let configuration: URLSessionConfiguration
        if let baseConfiguration = baseConfiguration {
            configuration = baseConfiguration
        } else {
            configuration = defaultBaseConfiguration
        }

        let session = defaultSession(withConfiguration: configuration)
        return Reactive(session)
    }

    // MARK: - Private

    private static func defaultSession(withConfiguration configuration: URLSessionConfiguration) -> Session {
        return
            Session(
                configuration: configuration,
                startRequestsImmediately: false,
                interceptor: defaultInterceptor)
    }

    private static let defaultBaseConfiguration: URLSessionConfiguration = {
        let configuration = Session.default.session.configuration

        if !Config.shared.general.httpRequestSendUserAgentHeader {
            configuration.removeHeader(header: HTTPHeader.Request.userAgent)
        }

        if !Config.shared.general.httpRequestSendAcceptLanguageHeader {
            configuration.removeHeader(header: HTTPHeader.Request.acceptLanguage)
        }

        return configuration
    }()

    private static var defaultInterceptor: Interceptor = {
        var retriers: [RequestRetrier] = []
        if Config.shared.general.retryingFailedNetworkRequests.shouldRetry {
            let retrier = HTTPRequestRetrier()
            retriers.append(retrier)
        }

        return .init(adapters: [], retriers: retriers)
    }()

}

private extension URLSessionConfiguration {

    func disableCaching() {
        urlCache = nil
        requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    }

    func removeHeader(header: Cornerstones.HTTPHeader.Request) {
        httpAdditionalHeaders?.removeValue(forKey: header.rawValue)
    }

}
