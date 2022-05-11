import Foundation

/// Generalized implementation of a `Request`.
public struct AnyRequest: Request {
    public let address: Address
    public let method: Method
    public let headers: Headers?
    public let queryItems: [URLQueryItem]?
    public let body: Data?
    
    public init(
        address: Address = .path(""),
        method: Method = .get,
        headers: Headers? = nil,
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil
    ) {
        self.address = address
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
    }
    
    public init<E>(
        address: Address = .path(""),
        method: Method = .get,
        headers: Headers? = nil,
        queryItems: [URLQueryItem]? = nil,
        encoding: E,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws where E: Encodable {
        self.address = address
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = try encoder.encode(encoding)
    }
    
    public init(
        path: String,
        method: Method = .get,
        headers: Headers? = nil,
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil
    ) {
        self.address = .path(path)
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
    }
    
    public init<E>(
        path: String,
        method: Method = .get,
        headers: Headers? = nil,
        queryItems: [URLQueryItem]? = nil,
        encoding: E,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws where E: Encodable {
        self.address = .path(path)
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = try encoder.encode(encoding)
    }
    
    public init(
        url: URL,
        method: Method = .get,
        headers: Headers? = nil,
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil
    ) {
        self.address = .absolute(url)
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
    }
    
    public init<E>(
        url: URL,
        method: Method = .get,
        headers: Headers? = nil,
        queryItems: [URLQueryItem]? = nil,
        encoding: E,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws where E: Encodable {
        self.address = .absolute(url)
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = try encoder.encode(encoding)
    }
}
