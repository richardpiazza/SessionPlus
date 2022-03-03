import Foundation

/// Generalized implementation of a `Request`.
public struct AnyRequest: Request {
    public let path: String
    public let method: Method
    public let headers: Headers?
    public let queryItems: [URLQueryItem]?
    public let body: Data?
    
    public init(
        path: String = "",
        method: Method = .get,
        headers: Headers? = nil,
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
    }
    
    public init<E>(
        path: String = "",
        method: Method = .get,
        headers: Headers? = nil,
        queryItems: [URLQueryItem]? = nil,
        encoding: E,
        encoder: JSONEncoder = JSONEncoder()
    ) throws where E: Encodable {
        self.path = path
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = try encoder.encode(encoding)
    }
}
