import Foundation

/// Encapsulation of output obtained while performing a request against an HTTP/REST service.
public protocol Response {
    /// Response code
    var statusCode: StatusCode { get }
    /// Response headers
    var headers: Headers { get }
    /// Binary data returned as output (potentially empty)
    var data: Data { get }
}
