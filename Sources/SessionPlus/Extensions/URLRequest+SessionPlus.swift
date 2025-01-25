import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension URLRequest {
    /// Initialize a `URLRequest` appropriate for JSON apis.
    ///
    /// - parameters:
    ///   - request: `Request` parameters used to customize the request.
    ///   - baseUrl: The root of the API address.
    init(request: Request, baseUrl: URL? = nil) throws {
        let url: URL
        switch request.address {
        case .absolute(let value):
            url = value
        case .path(let value):
            guard let baseURL = baseUrl else {
                throw URLError(.badURL)
            }
            
            let pathUrl = baseURL.appendingPathComponent(value)
            
            guard let queryItems = request.queryItems else {
                url = pathUrl
                break
            }
            
            guard var components = URLComponents(url: pathUrl, resolvingAgainstBaseURL: false) else {
                throw URLError(.badURL)
            }
            
            components.queryItems = queryItems
            
            guard let _url = components.url else {
                throw URLError(.badURL)
            }
            
            url = _url
        }
        
        self.init(url: url)
        
        httpMethod = request.method.rawValue
        setValue(Header.dateFormatter.string(from: Date()), forHeader: .date)
        setValue(.json, forHeader: .accept)
        
        if let body = request.body {
            httpBody = body
            setValue(.json, forHeader: .contentType)
            setValue("\(body.count)", forHeader: .contentLength)
        }
        
        if let headers = request.headers as? [String: String] {
            headers.forEach {
                setValue($0.value, forHTTPHeaderField: $0.key)
            }
        }
    }
    
    /// Sets a value for the header field.
    ///
    /// - parameters:
    ///   - value: The new value for the header field. Any existing value for the field is replaced by the new value.
    ///   - header: The header for which to set the value. (Headers are case sensitive)
    mutating func setValue(_ value: String, forHeader header: Header) {
        self.setValue(value, forHTTPHeaderField: header.rawValue)
    }
    
    /// Sets a value for the header field.
    ///
    /// - parameters:
    ///   - value: The new value for the header field. Any existing value for the field is replaced by the new value.
    ///   - header: The header for which to set the value. (Headers are case sensitive)
    mutating func setValue(_ value: MIMEType, forHeader header: Header) {
        self.setValue(value.rawValue, forHTTPHeaderField: header.rawValue)
    }
}
