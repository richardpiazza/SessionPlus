import Foundation
import Logging

/// Encapsulation of output obtained while performing a request against an HTTP/REST service.
public protocol Response {
    /// Response code
    var statusCode: StatusCode { get }
    /// Response headers
    var headers: Headers { get }
    /// Binary data returned as output (potentially empty)
    var body: Data { get }
}

extension Response {
    var metadata: Logger.Metadata {
        [
            "statusCode": .stringConvertible(statusCode),
            "bytes": .stringConvertible(body.count),
        ]
    }

    var verboseMetadata: Logger.Metadata {
        [
            "statusCode": .stringConvertible(statusCode),
            "bytes": .stringConvertible(body.count),
            "body": .string(String(decoding: body, as: UTF8.self)),
            "headers": .dictionary(headers.metadata),
        ]
    }
}
