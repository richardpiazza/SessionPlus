import Foundation

/// A convenience `Request` that uses `Method.delete`.
public struct Delete: Request {
    public let resource: Resource
    public let method: Method = .delete
    public let headers: Headers?
    public let queryItems: [QueryItem]?
    public let body: Data?

    @available(*, deprecated, renamed: "init(resource:headers:queryItems:body:)")
    public init(
        address: Address = .path(""),
        headers: Headers? = nil,
        queryItems: [QueryItem]? = nil,
        body: Data? = nil,
    ) {
        resource = address
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
    }

    @available(*, deprecated, renamed: "init(resource:headers:queryItems:encoding:using:)")
    public init(
        address: Address = .path(""),
        headers: Headers? = nil,
        queryItems: [QueryItem]? = nil,
        encoding: some Encodable,
        using encoder: JSONEncoder = JSONEncoder(),
    ) throws {
        resource = address
        self.headers = headers
        self.queryItems = queryItems
        body = try encoder.encode(encoding)
    }

    public init(
        resource: Resource = .path(""),
        headers: Headers? = nil,
        queryItems: [QueryItem]? = nil,
        body: Data? = nil,
    ) {
        self.resource = resource
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
    }

    public init(
        resource: Resource = .path(""),
        headers: Headers? = nil,
        queryItems: [QueryItem]? = nil,
        encoding: some Encodable,
        using encoder: JSONEncoder = JSONEncoder(),
    ) throws {
        self.resource = resource
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
        resource = .path(path)
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
        resource = .path(path)
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
        resource = .absolute(url)
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
        resource = .absolute(url)
        self.headers = headers
        self.queryItems = queryItems
        body = try encoder.encode(encoding)
    }
}
