// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Alamofire
import RxSwift

extension Session: ReactiveCompatible {}

public extension Reactive where Base: Session {

    // MARK: - Streaming status types

    enum DownloadStatus {
        case inProgress(progress: Double)
        case completed(fileURL: URL)
    }

    enum UploadStatus {
        case inProgress(progress: Double)
        case completed
    }

    // MARK: - Making requests

    /// Reactively makes an HTTP request for the specified payload type expected in the response.
    /// Possible payload types are: `Data`, `JSONDictionary`, and `JSONArray`.
    func making<ResponsePayload>(
        request: HTTPRequest, for _: ResponsePayload.Type, acceptForValidation: [HTTPContentType] = []) -> Os<HTTPResponse<ResponsePayload>> {

        // Output injection.
        if let injectedOutputResult = InstanceService.shared.outputForInput(request, outputType: HTTPResponse<ResponsePayload>.self) {
            var result = Os.just(injectedOutputResult.output)
            if let delay = injectedOutputResult.delay {
                result = result.delay(delay, scheduler: MainScheduler.instance)
            }
            return result
        }

        return
            Os.create(wrapIntoBackgroundTask: Config.shared.general.wrapEveryDataNetworkRequestIntoBackgroundTask) { [session = base] emitter in
                let urlRequest = request.asURLRequest(usingSession: session)
                var afRequest = session.request(urlRequest)

                if acceptForValidation._isNotEmpty {
                    let contentTypes = acceptForValidation.map { $0.string }
                    afRequest = afRequest.validate(contentType: contentTypes)
                }

                // Data.
                if Data.self is ResponsePayload.Type {
                    let afActiveRequest = afRequest.log().responseData { afResponse in
                        let anyErrors =
                            Self.processURLResponseCodeForErrors(afResponse.response, error: afResponse.error, onError: { error in emitter(.error(error)) })
                        if anyErrors {
                            return
                        }

                        switch afResponse.result {
                        case let .success(value):
                            if let urlResponse = afResponse.response {
                                let responseHeaders = Self.responseHeaders(fromURLResponse: urlResponse)
                                let response =
                                    HTTPResponse<ResponsePayload>(
                                        payload: value as! ResponsePayload, headers: responseHeaders, urlResponse: urlResponse, request: request)
                                emitter(.success(response))
                            } else {
                                let error: CoreError = .unknown
                                emitter(.error(error))
                            }
                        case let .failure(afError):
                            let error = CoreError(afError)
                            emitter(.error(error))
                        }
                    }

                    // Start the request.
                    afRequest.resume()

                    return Disposables.create { afActiveRequest.cancel() }
                }

                // JSON.
                if JSONDictionary.self is ResponsePayload.Type ||
                   JSONArray.self is ResponsePayload.Type {

                    let afActiveRequest = afRequest.log().responseJSON { afResponse in
                        let anyErrors =
                            Self.processURLResponseCodeForErrors(afResponse.response, error: afResponse.error, onError: { error in emitter(.error(error)) })
                        if anyErrors {
                            return
                        }

                        switch afResponse.result {
                        case let .success(value):
                            if let urlResponse = afResponse.response {
                                var jsonValue: Any?
                                if JSONDictionary.self is ResponsePayload.Type {
                                    jsonValue = value as? JSONDictionary
                                } else if JSONArray.self is ResponsePayload.Type {
                                    jsonValue = value as? JSONArray
                                }
                                guard let json = jsonValue else {
                                    let error: CoreError = .unexpectedHTTPResponsePayload
                                    emitter(.error(error))
                                    return
                                }

                                let responseHeaders = Self.responseHeaders(fromURLResponse: urlResponse)
                                let response =
                                    HTTPResponse<ResponsePayload>(
                                        payload: json as! ResponsePayload, headers: responseHeaders, urlResponse: urlResponse, request: request)
                                emitter(.success(response))
                            } else {
                                let error: CoreError = .unknown
                                emitter(.error(error))
                            }
                        case let .failure(afError):
                            let error = CoreError(afError)
                            emitter(.error(error))
                        }
                    }

                    // Start the request.
                    afRequest.resume()

                    return Disposables.create { afActiveRequest.cancel() }
                }

                assertionFailure("Unknown response payload")
                return Disposables.create()
            }
    }

    /// Reactively makes a stream of file downloading statuses for file downloading from a URL.
    func downloading(url: URL, acceptForValidation: [HTTPContentType] = []) -> O<DownloadStatus> {
        return
            O.create { [session = base] emitter in
                let destination: DownloadRequest.Destination = { _, _ in
                    let destinationFileURL = FileManager.generateTemporaryDocumentsFileURL()
                    return (destinationFileURL, [.removePreviousFile, .createIntermediateDirectories])
                }

                var afRequest = session.download(url, to: destination)

                if acceptForValidation._isNotEmpty {
                    let contentTypes = acceptForValidation.map { $0.string }
                    afRequest = afRequest.validate(contentType: contentTypes)
                }

                // Progress.
                afRequest.downloadProgress { progress in
                    emitter.send(.inProgress(progress: progress.fractionCompleted))
                }

                let afActiveRequest = afRequest.log().response { afResponse in
                    let anyErrors =
                        Self.processURLResponseCodeForErrors(afResponse.response, error: afResponse.error, onError: { error in emitter.sendError(error) })
                    if anyErrors {
                        return
                    }

                    if let afError = afResponse.error {
                        let error = CoreError(afError)
                        emitter.sendError(error)
                        return
                    }

                    if var fileURL = afResponse.fileURL {
                        // Completed.

                        if let urlResponse = afResponse.response {
                            let responseHeaders = Self.responseHeaders(fromURLResponse: urlResponse)
                            let contentType = responseHeaders[HTTPHeader.Response.contentType].flatMap { HTTPContentType(contentTypeString: $0) }
                            if let contentType = contentType {
                                // Rename the file to match its content type.
                                let newFileURL = FileManager.generateTemporaryDocumentsFileURL(forMimeType: contentType)
                                if (try? FileManager.default.moveItem(at: fileURL, to: newFileURL)) != nil {
                                    fileURL = newFileURL
                                }
                            }
                        }

                        emitter.send(.completed(fileURL: fileURL))
                        emitter.sendCompleted()
                    } else {
                        let error: CoreError = .unknown
                        emitter.sendError(error)
                    }
                }

                // Start the request.
                afRequest.resume()

                return Disposables.create { afActiveRequest.cancel() }
            }
    }

    /// Reactively makes a stream of file uploading statuses for file uploading to a URL.
    func uploadingFile(withURL fileURL: URL, toURL url: URL) -> O<UploadStatus> {
        return
            O.create { [session = base] emitter in
                let afRequest = session.upload(fileURL, to: url)

                // Progress.
                afRequest.uploadProgress { progress in
                    emitter.send(.inProgress(progress: progress.fractionCompleted))
                }

                let afActiveRequest = afRequest.log().response { afResponse in
                    let anyErrors =
                        Self.processURLResponseCodeForErrors(afResponse.response, error: afResponse.error, onError: { error in emitter.sendError(error) })
                    if anyErrors {
                        return
                    }

                    if let afError = afResponse.error {
                        let error = CoreError(afError)
                        emitter.sendError(error)
                        return
                    }

                    // Completed.
                    emitter.send(.completed)
                    emitter.sendCompleted()
                }

                // Start the request.
                afRequest.resume()

                return Disposables.create { afActiveRequest.cancel() }
            }
    }

    /// Reactively makes a stream of data uploading statuses for data uploading to a URL.
    func uploadingData(_ data: @autoclosure @escaping () -> Data, toURL url: URL) -> O<UploadStatus> {
        return
            O.create { [session = base] emitter in
                let afRequest = session.upload(data(), to: url)

                // Progress.
                afRequest.uploadProgress { progress in
                    emitter.send(.inProgress(progress: progress.fractionCompleted))
                }

                let afActiveRequest = afRequest.log().response { afResponse in
                    let anyErrors =
                        Self.processURLResponseCodeForErrors(afResponse.response, error: afResponse.error, onError: { error in emitter.sendError(error) })
                    if anyErrors {
                        return
                    }

                    if let afError = afResponse.error {
                        let error = CoreError(afError)
                        emitter.sendError(error)
                        return
                    }

                    // Completed.
                    emitter.send(.completed)
                    emitter.sendCompleted()
                }

                // Start the request.
                afRequest.resume()

                return Disposables.create { afActiveRequest.cancel() }
            }
    }

    // MARK: - Specializations

    func makingForData(request: HTTPRequest, acceptForValidation: [HTTPContentType] = []) -> Os<HTTPDataResponse> {
        return making(request: request, for: Data.self, acceptForValidation: acceptForValidation)
    }

    // MARK: - Private

    private static func processURLResponseCodeForErrors(_ urlResponse: HTTPURLResponse?, error: Error?, onError: @escaping ((_: CoreError) -> Void)) -> Bool {
        if let statusCodeInt = urlResponse?.statusCode {
            let statusCode = HTTPStatusCode(statusCodeInt)

            if statusCode == .unauthorized {
                let error: CoreError = .notAuthenticated
                onError(error)
                return true
            }

            if statusCode.isServerError && Config.shared.general.acknowledgeServerErrors {
                let error: CoreError = .serverError
                onError(error)
                return true
            }

            if statusCode == .notFound && Config.shared.general.acknowledgeHTTPResponseNotFoundErrors {
                let error: CoreError = .networkResponseNotFound
                onError(error)
                return true
            }

            if statusCode.isError && Config.shared.general.acknowledgeHTTPResponseErrorCodes {
                let error: CoreError = .httpErrorCode
                onError(error)
                return true
            }
        }

        if let error = error?.asAFError {
            if case .responseValidationFailed = error {
                let error: CoreError = .unexpectedHTTPResponseContentType
                onError(error)
                return true
            }
        }

        return false
    }

    private static func responseHeaders(fromURLResponse urlResponse: HTTPURLResponse) -> [Cornerstones.HTTPHeader.Response: String] {
        return
            .init(uniqueKeysWithValues:
                urlResponse.allHeaderFields.compactMap { key, value -> (Cornerstones.HTTPHeader.Response, String)? in
                    guard let keyString = key as? String else { return nil }
                    guard let valueString = value as? String else { return nil }
                    guard let header = HTTPHeader.Response(headerName: keyString) else { return nil }
                    return (header, valueString)
                })
    }

}

private extension Request {
    func log() -> Self {
        if Config.shared.general.curlPrintHTTPRequests {
            debugPrint(self)
        }
        return self
    }
}
