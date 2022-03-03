import Foundation

/// Generalized implementation of a `Response`
public struct AnyResponse: Response {
    public let statusCode: StatusCode
    public let headers: Headers
    public let duration: TimeInterval
    public let data: Data
    
    public init(
        statusCode: StatusCode = .ok,
        headers: Headers = [:],
        duration: TimeInterval = 0.0,
        data: Data = Data()
    ) {
        self.statusCode = statusCode
        self.headers = headers
        self.duration = duration
        self.data = data
    }
}
