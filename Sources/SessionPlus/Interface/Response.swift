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
    var description: String {
        String(
            format: "%1$@, Headers: %2$d, Bytes: %3$d",
            statusCode.description,
            headers.count,
            body.count,
        )
    }

    var debugDescription: String {
        let debugHeaders = headers
            .map { "\($0.key) = \($0.value)" }
            .joined(separator: " ")

        let debugBody = String(decoding: body, as: UTF8.self)

        return String(
            format: "%1$@, Headers: %2$@, Body: %3$@",
            statusCode.description,
            debugHeaders,
            debugBody,
        )
    }

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
