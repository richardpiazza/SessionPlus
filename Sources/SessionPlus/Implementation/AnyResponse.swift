import Foundation

/// Generalized implementation of a `Response`
public struct AnyResponse: Response {
    public let statusCode: StatusCode
    public let headers: Headers
    public let data: Data
    
    public init(
        statusCode: StatusCode = .ok,
        headers: Headers = [:],
        data: Data = Data()
    ) {
        self.statusCode = statusCode
        self.headers = headers
        self.data = data
    }
}
