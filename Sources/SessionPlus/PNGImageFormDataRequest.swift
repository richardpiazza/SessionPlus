import Foundation

/// A `multipart/form-data` request for PNG image uploading.
public struct PNGImageFormDataRequest: Request {
    public let path: String
    public let method: Method
    public let headers: Headers?
    public let queryItems: [URLQueryItem]?
    public let body: Data?
    
    public init(
        path: String = "",
        method: Method = .post,
        headers: Headers? = nil,
        queryItems: [URLQueryItem]? = nil,
        field: String = "image",
        filename: String = "image.png",
        imageData: Data
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        
        let boundary = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let contentType = "multipart/form-data; boundary=\(boundary)"
        
        var headers = headers ?? [:]
        headers[.contentType] = contentType
        self.headers = headers
        
        let prefix = """
        --\(boundary)
        Content-Disposition: form-data; name=\"\(field)\"; filename=\"\(filename)\"
        Content-Type: image/png
        
        
        """
        
        let suffix = """
        
        --\(boundary)--
        
        """
        
        var data = Data()
        let chunks = [prefix.data(using: .utf8), imageData, suffix.data(using: .utf8)]
        chunks.compactMap { $0 }.forEach { data.append($0) }
        
        self.body = data
    }
}
