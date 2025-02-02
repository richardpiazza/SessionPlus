import Foundation

/// Generalized implementation of a `Response`
public struct AnyResponse: Response {
    public let statusCode: StatusCode
    public let headers: Headers
    public let body: Data

    public init(
        statusCode: StatusCode = .ok,
        headers: Headers = [:],
        body: Data = Data()
    ) {
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
    }
}
