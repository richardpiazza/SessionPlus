/// Status codes are issued by a server in response to a client's request made to the server.
///
/// All HTTP response status codes are separated into five classes or categories:
/// * 1xx Informational: The request was received, continuing process.
/// * 2xx Success: The request was successfully received, understood, and accepted.
/// * 3xx Redirection: Further action needs to be taken in order to complete the request.
/// * 4xx Client Error: The request contains bad syntax or cannot be fulfilled.
/// * 5xx Server Error: The server failed to fulfill an apparently valid request.
public struct StatusCode: ExpressibleByIntegerLiteral, Hashable {
    public let rawValue: Int

    public init(integerLiteral value: IntegerLiteralType) {
        rawValue = value
    }
}

extension StatusCode: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(Int.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension StatusCode: Comparable {
    public static func < (lhs: StatusCode, rhs: StatusCode) -> Bool { lhs.rawValue < rhs.rawValue }
}

extension StatusCode: Identifiable {
    public var id: Int { rawValue }
}

extension StatusCode: CustomStringConvertible {
    public var description: String { "\(rawValue)" }
}

public extension StatusCode {
    // MARK: - Success

    /// **200** Standard response for successful HTTP requests.
    static let ok: Self = 200
    /// **201** The request has been fulfilled, resulting in the creation of a new resource.
    static let created: Self = 201
    /// **202** The request has been accepted for processing, but the processing has not been completed.
    static let accepted: Self = 202
    /// **204** The server successfully processed the request, and is not returning any content.
    static let noContent: Self = 204

    // MARK: - Redirection

    /// **301** This and all future requests should be directed to the given URI.
    static let movedPermanently: Self = 301
    /// **303** The response to the request can be found under another URI using the GET method.
    static let seeOther: Self = 303
    /// **307** In this case, the request should be repeated with another URI; however, future requests should still use the original URI
    static let temporaryRedirect: Self = 307

    // MARK: - Client Errors

    /// **400** The server cannot or will not process the request due to an apparent client error
    static let badRequest: Self = 400
    /// **401** Similar to 403 Forbidden, but specifically for use when authentication is required and has failed or has not yet been provided.
    static let unauthorized: Self = 401
    /// **403** The request contained valid data and was understood by the server, but the server is refusing action.
    static let forbidden: Self = 403
    /// **404** The requested resource could not be found but may be available in the future.
    static let notFound: Self = 404
    /// **408** The server timed out waiting for the request.
    static let requestTimeout: Self = 408
    /// **409** Indicates that the request could not be processed because of conflict in the current state of the resource, such as an edit conflict between multiple simultaneous updates.
    static let conflict: Self = 409
    /// **418** RFC 2324 specifies this code should be returned by teapots requested to brew coffee.
    static let iAmATeapot: Self = 418
    /// **429** The user has sent too many requests in a given amount of time.
    static let tooManyRequests: Self = 429

    // MARK: - Server Errors

    /// **500** A generic error message, given when an unexpected condition was encountered and no more specific message is suitable.
    static let internalServerError: Self = 500
    /// **501** The server either does not recognize the request method, or it lacks the ability to fulfill the request.
    static let notImplemented: Self = 501
    /// **502** The server was acting as a gateway or proxy and received an invalid response from the upstream server.
    static let badGateway: Self = 502
    /// **503** The server cannot handle the request (because it is overloaded or down for maintenance).
    static let serviceUnavailable: Self = 503
    /// **504** The server was acting as a gateway or proxy and did not receive a timely response from the upstream server.
    static let gatewayTimeout: Self = 504
}
