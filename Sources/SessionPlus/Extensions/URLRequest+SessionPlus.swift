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
    init(request: Request, baseUrl: URL) throws {
        self.init(url: try request.url(using: baseUrl))
        
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

public extension URLRequest {
    @available(*, deprecated, renamed: "setValue(_:forHeader:)")
    mutating func setValue(_ value: String, forHTTPHeader header: Header) {
        setValue(value, forHeader: header)
    }
    
    @available(*, deprecated, renamed: "setValue(_:forHeader:)")
    mutating func setValue(_ value: HTTP.MIMEType, forHTTPHeader header: Header) {
        setValue(value.rawValue, forHeader: header)
    }
}
