//
//  HTTPStatusCode.swift
//  higi
//
//  Created by Remy Panicker on 3/26/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

import Foundation

public let HTTPErrorDomain = "com.higi.main.HTTP.HTTPErrorDomain"

struct HTTPHeader {
    struct name {
        static let contentType = "Content-Type"
    }
    
    struct value {
        static let applicationJSON = "application/json"
    }
}

/**
 HTTP Methods as defined in _Section 4.3 Method Definitions_ of [RFC 7231](https://tools.ietf.org/html/rfc7231)
 
 - GET:     Requests transfer of a current selected representation
 for the target resource
 - HEAD:    Method is identical to GET except that the server MUST NOT
 send a message body in the response
 - POST:    Requests that the target resource process the
 representation enclosed in the request according to the resource's
 own specific semantics.
 - PUT:     Requests that the state of the target resource be
 created or replaced with the state defined by the representation
 enclosed in the request message payload.
 - DELETE:  Requests that the origin server remove the
 association between the target resource and its current
 functionality.
 - CONNECT: Requests that the recipient establish a tunnel to
 the destination origin server identified by the request-target and,
 if successful, thereafter restrict its behavior to blind forwarding
 of packets, in both directions, until the tunnel is closed.
 - OPTIONS: Requests information about the communication
 options available for the target resource, at either the origin
 server or an intervening intermediary.
 - TRACE:   Requests a remote, application-level loop-back of
 the request message.
 
 */
struct HTTPMethod {
    static let GET: String = "GET"
    static let HEAD: String = "HEAD"
    static let POST: String = "POST"
    static let PUT: String = "PUT"
    static let DELETE: String = "DELETE"
    static let CONNECT: String = "CONNECT"
    static let OPTIONS: String = "OPTIONS"
    static let TRACE: String = "TRACE"
}

/**
 HTTP status codes as per [Wikipedia](http://en.wikipedia.org/wiki/List_of_HTTP_status_codes).
 
 The [RF2616](http://www.ietf.org/rfc/rfc2616.txt) standard is completely covered.
 */
@objc public enum HTTPStatusCode: Int {
    // Informational
    case Continue = 100
    case SwitchingProtocols = 101
    case Processing = 102
    
    // Success
    case OK = 200
    case Created = 201
    case Accepted = 202
    case NonAuthoritativeInformation = 203
    case NoContent = 204
    case ResetContent = 205
    case PartialContent = 206
    case MultiStatus = 207
    case AlreadyReported = 208
    case IMUsed = 226
    
    // Redirections
    case MultipleChoices = 300
    case MovedPermanently = 301
    case Found = 302
    case SeeOther = 303
    case NotModified = 304
    case UseProxy = 305
    case SwitchProxy = 306
    case TemporaryRedirect = 307
    case PermanentRedirect = 308
    
    // Client Errors
    case BadRequest = 400
    case Unauthorized = 401
    case PaymentRequired = 402
    case Forbidden = 403
    case NotFound = 404
    case MethodNotAllowed = 405
    case NotAcceptable = 406
    case ProxyAuthenticationRequired = 407
    case RequestTimeout = 408
    case Conflict = 409
    case Gone = 410
    case LengthRequired = 411
    case PreconditionFailed = 412
    case RequestEntityTooLarge = 413
    case RequestURITooLong = 414
    case UnsupportedMediaType = 415
    case RequestedRangeNotSatisfiable = 416
    case ExpectationFailed = 417
    case ImATeapot = 418
    case AuthenticationTimeout = 419
    case UnprocessableEntity = 422
    case Locked = 423
    case FailedDependency = 424
    case UpgradeRequired = 426
    case PreconditionRequired = 428
    case TooManyRequests = 429
    case RequestHeaderFieldsTooLarge = 431
    case LoginTimeout = 440
    case NoResponse = 444
    case RetryWith = 449
    case UnavailableForLegalReasons = 451
    case RequestHeaderTooLarge = 494
    case CertError = 495
    case NoCert = 496
    case HTTPToHTTPS = 497
    case TokenExpired = 498
    case ClientClosedRequest = 499
    
    // Server Errors
    case InternalServerError = 500
    case NotImplemented = 501
    case BadGateway = 502
    case ServiceUnavailable = 503
    case GatewayTimeout = 504
    case HTTPVersionNotSupported = 505
    case VariantAlsoNegotiates = 506
    case InsufficientStorage = 507
    case LoopDetected = 508
    case BandwidthLimitExceeded = 509
    case NotExtended = 510
    case NetworkAuthenticationRequired = 511
    case NetworkTimeoutError = 599
}

public extension HTTPStatusCode {
    
}

public extension HTTPStatusCode {
    /// Informational - Request received, continuing process.
    public var isInformational: Bool {
        return inRange(100...199)
    }
    /// Success - The action was successfully received, understood, and accepted.
    public var isSuccess: Bool {
        return inRange(200...299)
    }
    /// Redirection - Further action must be taken in order to complete the request.
    public var isRedirection: Bool {
        return inRange(300...399)
    }
    /// Client Error - The request contains bad syntax or cannot be fulfilled.
    public var isClientError: Bool {
        return inRange(400...499)
    }
    /// Server Error - The server failed to fulfill an apparently valid request.
    public var isServerError: Bool {
        return inRange(500...599)
    }
    
    /// - returns: `true` if the status code is in the provided range, false otherwise.
    private func inRange(range: Range<Int>) -> Bool {
        return range.contains(rawValue)
    }
}

public extension HTTPStatusCode {
    /// - returns: a localized string suitable for displaying to users that describes the specified status code.
    public var localizedReasonPhrase: String {
        return NSHTTPURLResponse.localizedStringForStatusCode(rawValue)
    }
}

// MARK: - Printing

extension HTTPStatusCode: CustomDebugStringConvertible, CustomStringConvertible {
    public var description: String {
        return "\(rawValue) - \(localizedReasonPhrase)"
    }
    public var debugDescription: String {
        return "HTTPStatusCode:\(description)"
    }
}

// MARK: - HTTP URL Response

public extension HTTPStatusCode {
    /// Obtains a possible status code from an optional HTTP URL response.
    public init?(HTTPResponse: NSHTTPURLResponse?) {
        if let value = HTTPResponse?.statusCode {
            self.init(rawValue: value)
        } else {
            return nil
        }
    }
}

public extension NSHTTPURLResponse {
    
    /**
     * Marked internal to expose (as `statusCodeValue`) for Objective-C interoperability only.
     *
     * - returns: the receiver’s HTTP status code.
     */
    @objc(statusCodeValue) var statusCodeEnum: HTTPStatusCode {
        return HTTPStatusCode(HTTPResponse: self)!
    }
    
    /// - returns: the receiver’s HTTP status code.
    public var statusCodeValue: HTTPStatusCode? {
        return HTTPStatusCode(HTTPResponse: self)
    }
}
