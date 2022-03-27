import Foundation

/// A convenience `Request` that uses `Method.delete`.
public struct Delete: Request {
    public let path: String
    public let method: Method = .delete
    public let headers: Headers?
    public let queryItems: [URLQueryItem]?
    public let body: Data?
    
    public init(
        path: String = "",
        headers: Headers? = nil,
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil
    ) {
        self.path = path
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
        self.path = path
        self.headers = headers
        self.queryItems = queryItems
        self.body = try encoder.encode(encoding)
    }
}
