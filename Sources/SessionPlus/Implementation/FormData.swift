import Foundation

/// A `multipart/form-data` request for file uploading.
public struct FormData: Request {
    public let resource: Resource
    public let method: Method
    public let headers: Headers?
    public let queryItems: [QueryItem]?
    public let body: Data?

    @available(*, deprecated, renamed: "init(resource:method:headers:queryItems:field:filename:mimeType:content:)")
    public init(
        _ address: Address,
        method: Method = .post,
        headers: Headers? = nil,
        queryItems: [QueryItem]? = nil,
        field: String = "file",
        filename: String,
        mimeType: MIMEType,
        content: Data,
    ) {
        resource = address
        self.method = method
        self.queryItems = queryItems

        let data = Self.data(
            field: field,
            filename: filename,
            mimeType: mimeType,
            content: content,
        )

        var headers = headers ?? [:]
        headers[.contentType] = "multipart/form-data; boundary=\(data.boundary)"
        self.headers = headers
        body = data.data
    }

    public init(
        resource: Resource,
        method: Method = .post,
        headers: Headers? = nil,
        queryItems: [QueryItem]? = nil,
        field: String = "file",
        filename: String,
        mimeType: MIMEType,
        content: Data,
    ) {
        self.resource = resource
        self.method = method
        self.queryItems = queryItems

        let data = Self.data(
            field: field,
            filename: filename,
            mimeType: mimeType,
            content: content,
        )

        var headers = headers ?? [:]
        headers[.contentType] = "multipart/form-data; boundary=\(data.boundary)"
        self.headers = headers
        body = data.data
    }

    public init(
        path: String,
        method: Method = .post,
        headers: Headers? = nil,
        queryItems: [QueryItem]? = nil,
        field: String = "file",
        filename: String,
        mimeType: MIMEType,
        content: Data,
    ) {
        resource = .path(path)
        self.method = method
        self.queryItems = queryItems

        let data = Self.data(
            field: field,
            filename: filename,
            mimeType: mimeType,
            content: content,
        )

        var headers = headers ?? [:]
        headers[.contentType] = "multipart/form-data; boundary=\(data.boundary)"
        self.headers = headers
        body = data.data
    }

    public init(
        url: URL,
        method: Method = .post,
        headers: Headers? = nil,
        queryItems: [QueryItem]? = nil,
        field: String = "file",
        filename: String,
        mimeType: MIMEType,
        content: Data,
    ) {
        resource = .absolute(url)
        self.method = method
        self.queryItems = queryItems

        let data = Self.data(
            field: field,
            filename: filename,
            mimeType: mimeType,
            content: content,
        )

        var headers = headers ?? [:]
        headers[.contentType] = "multipart/form-data; boundary=\(data.boundary)"
        self.headers = headers
        body = data.data
    }

    private static func data(
        field: String,
        filename: String,
        mimeType: MIMEType,
        content: Data,
    ) -> (boundary: String, data: Data) {
        let boundary = UUID().uuidString.replacingOccurrences(of: "-", with: "")

        var data = Data()
        let chunks = [
            "--\(boundary)".data(using: .utf8),
            "\r\n".data(using: .utf8),
            "Content-Disposition: form-data; name=\"\(field)\"; filename=\"\(filename)\"\r\n".data(using: .utf8),
            "Content-Type: \(mimeType.rawValue)\r\n\r\n".data(using: .utf8),
            content,
            "\r\n".data(using: .utf8),
            "--\(boundary)--".data(using: .utf8),
            "\r\n".data(using: .utf8),
        ]
        chunks.compactMap(\.self).forEach { data.append($0) }

        return (boundary, data)
    }
}
