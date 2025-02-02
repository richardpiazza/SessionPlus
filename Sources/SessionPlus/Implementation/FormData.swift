import Foundation

/// A `multipart/form-data` request for file uploading.
public struct FormData: Request {
    public let address: Address
    public let method: Method
    public let headers: Headers?
    public let queryItems: [QueryItem]?
    public let body: Data?

    public init(
        _ address: Address,
        method: Method = .post,
        headers: Headers? = nil,
        queryItems: [QueryItem]? = nil,
        field: String = "file",
        filename: String,
        mimeType: MIMEType,
        content: Data
    ) {
        self.address = address
        self.method = method
        self.queryItems = queryItems

        let data = Self.data(
            field: field,
            filename: filename,
            mimeType: mimeType,
            content: content
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
        content: Data
    ) {
        address = .path(path)
        self.method = method
        self.queryItems = queryItems

        let data = Self.data(
            field: field,
            filename: filename,
            mimeType: mimeType,
            content: content
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
        content: Data
    ) {
        address = .absolute(url)
        self.method = method
        self.queryItems = queryItems

        let data = Self.data(
            field: field,
            filename: filename,
            mimeType: mimeType,
            content: content
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
        content: Data
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
        chunks.compactMap { $0 }.forEach { data.append($0) }

        return (boundary, data)
    }
}
