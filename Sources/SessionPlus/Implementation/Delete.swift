import Foundation

/// A convenience `Request` that uses `Method.delete`.
public struct Delete: Request {
    public let address: Address
    public let method: Method = .delete
    public let headers: Headers?
    public let queryItems: [QueryItem]?
    public let body: Data?

    public init(
        address: Address = .path(""),
        headers: Headers? = nil,
        queryItems: [QueryItem]? = nil,
        body: Data? = nil,
    ) {
        self.address = address
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
    }

    public init(
        address: Address = .path(""),
        headers: Headers? = nil,
        queryItems: [QueryItem]? = nil,
        encoding: some Encodable,
        using encoder: JSONEncoder = JSONEncoder(),
    ) throws {
        self.address = address
        self.headers = headers
        self.queryItems = queryItems
        body = try encoder.encode(encoding)
    }

    public init(
        path: String,
        headers: Headers? = nil,
        queryItems: [QueryItem]? = nil,
        body: Data? = nil,
    ) {
        address = .path(path)
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
    }

    public init(
        path: String,
        headers: Headers? = nil,
        queryItems: [QueryItem]? = nil,
        encoding: some Encodable,
        using encoder: JSONEncoder = JSONEncoder(),
    ) throws {
        address = .path(path)
        self.headers = headers
        self.queryItems = queryItems
        body = try encoder.encode(encoding)
    }

    public init(
        url: URL,
        headers: Headers? = nil,
        queryItems: [QueryItem]? = nil,
        body: Data? = nil,
    ) {
        address = .absolute(url)
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
    }

    public init(
        url: URL,
        headers: Headers? = nil,
        queryItems: [QueryItem]? = nil,
        encoding: some Encodable,
        using encoder: JSONEncoder = JSONEncoder(),
    ) throws {
        address = .absolute(url)
        self.headers = headers
        self.queryItems = queryItems
        body = try encoder.encode(encoding)
    }
}
