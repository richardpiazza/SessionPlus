import Foundation

/// A `multipart/form-data` request for PNG image uploading.
public struct PNGImageFormDataRequest: Request {
    public let address: Address
    public let method: Method
    public let headers: Headers?
    public let queryItems: [URLQueryItem]?
    public let body: Data?
    
    public init(
        address: Address = .path(""),
        method: Method = .post,
        headers: Headers? = nil,
        queryItems: [URLQueryItem]? = nil,
        field: String = "image",
        filename: String = "image.png",
        imageData: Data
    ) {
        self.address = address
        self.method = method
        self.queryItems = queryItems
        
        let data = Self.data(field: field, filename: filename, imageData: imageData)
        
        var headers = headers ?? [:]
        headers[.contentType] = "multipart/form-data; boundary=\(data.boundary)"
        self.headers = headers
        self.body = data.data
    }
    
    public init(
        path: String = "",
        method: Method = .post,
        headers: Headers? = nil,
        queryItems: [URLQueryItem]? = nil,
        field: String = "image",
        filename: String = "image.png",
        imageData: Data
    ) {
        self.address = .path(path)
        self.method = method
        self.queryItems = queryItems
        
        let data = Self.data(field: field, filename: filename, imageData: imageData)
        
        var headers = headers ?? [:]
        headers[.contentType] = "multipart/form-data; boundary=\(data.boundary)"
        self.headers = headers
        self.body = data.data
    }
    
    private static func data(field: String, filename: String, imageData: Data) -> (boundary: String, data: Data) {
        let boundary = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        
        var data = Data()
        let chunks = [
            "--\(boundary)".data(using: .utf8),
            "\r\n".data(using: .utf8),
            "Content-Disposition: form-data; name=\"\(field)\"; filename=\"\(filename)\"\r\n".data(using: .utf8),
            "Content-Type: image/png\r\n\r\n".data(using: .utf8),
            imageData,
            "\r\n".data(using: .utf8),
            "--\(boundary)--".data(using: .utf8),
            "\r\n".data(using: .utf8)
        ]
        chunks.compactMap { $0 }.forEach { data.append($0) }
        
        return (boundary, data)
    }
}
