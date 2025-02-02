import Foundation

/// Generalized implementation of a `Request`.
public struct AnyRequest: Request {
    public let address: Address
    public let method: Method
    public let headers: Headers?
    public let queryItems: [QueryItem]?
    public let body: Data?

    public init(
        address: Address = .path(""),
        method: Method = .get,
        headers: Headers? = nil,
        queryItems: [QueryItem]? = nil,
        body: Data? = nil
    ) {
        self.address = address
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
    }

    public init(
        address: Address = .path(""),
        method: Method = .get,
        headers: Headers? = nil,
        queryItems: [QueryItem]? = nil,
        encoding: some Encodable,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws {
        self.address = address
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        body = try encoder.encode(encoding)
    }

    public init(
        path: String,
        method: Method = .get,
        headers: Headers? = nil,
        queryItems: [QueryItem]? = nil,
        body: Data? = nil
    ) {
        address = .path(path)
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
    }

    public init(
        path: String,
        method: Method = .get,
        headers: Headers? = nil,
        queryItems: [QueryItem]? = nil,
        encoding: some Encodable,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws {
        address = .path(path)
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        body = try encoder.encode(encoding)
    }

    public init(
        url: URL,
        method: Method = .get,
        headers: Headers? = nil,
        queryItems: [QueryItem]? = nil,
        body: Data? = nil
    ) {
        address = .absolute(url)
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
    }

    public init(
        url: URL,
        method: Method = .get,
        headers: Headers? = nil,
        queryItems: [QueryItem]? = nil,
        encoding: some Encodable,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws {
        address = .absolute(url)
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        body = try encoder.encode(encoding)
    }
}
