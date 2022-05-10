import Foundation

/// A convenience `Request` that uses `Method.post`.
public struct Post: Request {
    public let address: Address
    public let method: Method = .post
    public let headers: Headers?
    public let queryItems: [URLQueryItem]?
    public let body: Data?
    
    public init(
        address: Address = .path(""),
        headers: Headers? = nil,
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil
    ) {
        self.address = address
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
    }
    
    public init<E>(
        address: Address = .path(""),
        headers: Headers? = nil,
        queryItems: [URLQueryItem]? = nil,
        encoding: E,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws where E: Encodable {
        self.address = address
        self.headers = headers
        self.queryItems = queryItems
        self.body = try encoder.encode(encoding)
    }
    
    public init(
        path: String = "",
        headers: Headers? = nil,
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil
    ) {
        self.address = .path(path)
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
    }
    
    public init<E>(
        path: String = "",
        headers: Headers? = nil,
        queryItems: [URLQueryItem]? = nil,
        encoding: E,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws where E: Encodable {
        self.address = .path(path)
        self.headers = headers
        self.queryItems = queryItems
        self.body = try encoder.encode(encoding)
    }
}
