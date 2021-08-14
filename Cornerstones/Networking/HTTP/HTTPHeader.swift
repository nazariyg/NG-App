// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public enum HTTPHeader {

    public enum Request: String, CaseIterable {

        case aim = "A-IM"
        case accept = "Accept"
        case acceptCharset = "Accept-Charset"
        case acceptDatetime = "Accept-Datetime"
        case acceptEncoding = "Accept-Encoding"
        case acceptLanguage = "Accept-Language"
        case accessControlRequestHeaders = "Access-Control-Request-Headers"
        case accessControlRequestMethod = "Access-Control-Request-Method"
        case authorization = "Authorization"
        case cacheControl = "Cache-Control"
        case connection = "Connection"
        case contentLength = "Content-Length"
        case contentMD5 = "Content-MD5"
        case contentType = "Content-Type"
        case cookie = "Cookie"
        case date = "Date"
        case dnt = "DNT"
        case expect = "Expect"
        case forwarded = "Forwarded"
        case from = "From"
        case frontEndHTTPS = "Front-End-Https"
        case host = "Host"
        case http2Settings = "HTTP2-Settings"
        case ifMatch = "If-Match"
        case ifModifiedSince = "If-Modified-Since"
        case ifNoneMatch = "If-None-Match"
        case ifRange = "If-Range"
        case ifUnmodifiedSince = "If-Unmodified-Since"
        case maxForwards = "Max-Forwards"
        case origin = "Origin"
        case pragma = "Pragma"
        case proxyAuthorization = "Proxy-Authorization"
        case proxyConnection = "Proxy-Connection"
        case range = "Range"
        case referer = "Referer"
        case saveData = "Save-Data"
        case te = "TE"
        case upgrade = "Upgrade"
        case upgradeInsecureRequests = "Upgrade-Insecure-Requests"
        case userAgent = "User-Agent"
        case via = "Via"
        case warning = "Warning"
        case xATTDeviceId = "X-ATT-DeviceId"
        case xCorrelationID = "X-Correlation-ID"
        case xCsrfToken = "X-Csrf-Token"
        case xForwardedFor = "X-Forwarded-For"
        case xForwardedHost = "X-Forwarded-Host"
        case xForwardedProto = "X-Forwarded-Proto"
        case xHTTPMethodOverride = "X-Http-Method-Override"
        case xRequestID = "X-Request-ID"
        case xRequestedWith = "X-Requested-With"
        case xUIDH = "X-UIDH"
        case xWapProfile = "X-Wap-Profile"

        /// Constructs a request header from a header name. Case-insensitive.
        public init?(headerName: String) {
            let headerNameLowercased = headerName.lowercased()
            let foundCase = Self.allCases.first { $0.rawValue.lowercased() == headerNameLowercased }
            if let foundCase = foundCase {
                self = foundCase
            } else {
                return nil
            }
        }

    }

    public enum Response: String, CaseIterable {

        case acceptPatch = "Accept-Patch"
        case acceptRanges = "Accept-Ranges"
        case accessControlAllowCredentials = "Access-Control-Allow-Credentials"
        case accessControlAllowHeaders = "Access-Control-Allow-Headers"
        case accessControlAllowMethods = "Access-Control-Allow-Methods"
        case accessControlAllowOrigin = "Access-Control-Allow-Origin"
        case accessControlExposeHeaders = "Access-Control-Expose-Headers"
        case accessControlMaxAge = "Access-Control-Max-Age"
        case age = "Age"
        case allow = "Allow"
        case altSvc = "Alt-Svc"
        case cacheControl = "Cache-Control"
        case connection = "Connection"
        case contentDisposition = "Content-Disposition"
        case contentEncoding = "Content-Encoding"
        case contentLanguage = "Content-Language"
        case contentLength = "Content-Length"
        case contentLocation = "Content-Location"
        case contentMD5 = "Content-MD5"
        case contentRange = "Content-Range"
        case contentSecurityPolicy = "Content-Security-Policy"
        case contentType = "Content-Type"
        case date = "Date"
        case deltaBase = "Delta-Base"
        case eTag = "ETag"
        case expires = "Expires"
        case im = "IM"
        case lastModified = "Last-Modified"
        case link = "Link"
        case location = "Location"
        case p3p = "P3P"
        case pragma = "Pragma"
        case proxyAuthenticate = "Proxy-Authenticate"
        case publicKeyPins = "Public-Key-Pins"
        case refresh = "Refresh"
        case retryAfter = "Retry-After"
        case server = "Server"
        case setCookie = "Set-Cookie"
        case status = "Status"
        case strictTransportSecurity = "Strict-Transport-Security"
        case timingAllowOrigin = "Timing-Allow-Origin"
        case tk = "Tk"
        case trailer = "Trailer"
        case transferEncoding = "Transfer-Encoding"
        case upgrade = "Upgrade"
        case vary = "Vary"
        case via = "Via"
        case warning = "Warning"
        case wwwAuthenticate = "WWW-Authenticate"
        case xContentDuration = "X-Content-Duration"
        case xContentSecurityPolicy = "X-Content-Security-Policy"
        case xContentTypeOptions = "X-Content-Type-Options"
        case xCorrelationID = "X-Correlation-ID"
        case xFrameOptions = "X-Frame-Options"
        case xPoweredBy = "X-Powered-By"
        case xRequestID = "X-Request-ID"
        case xUACompatible = "X-UA-Compatible"
        case xWebKitCSP = "X-WebKit-CSP"
        case xXSSProtection = "X-XSS-Protection"

        /// Constructs a response header from a header name. Case-insensitive.
        public init?(headerName: String) {
            let headerNameLowercased = headerName.lowercased()
            let foundCase = Self.allCases.first { $0.rawValue.lowercased() == headerNameLowercased }
            if let foundCase = foundCase {
                self = foundCase
            } else {
                return nil
            }
        }

    }

}
