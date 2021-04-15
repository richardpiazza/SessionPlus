import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A Collection of methods/headers/values/types used during basic HTTP interactions.
public struct HTTP {
    
    /// HTTP Headers as provided from HTTPURLResponse
    public typealias Headers = [AnyHashable : Any]
    
    /// Authorization schemes used in the API
    public enum Authorization {
        case basic(username: String, password: String?)
        case bearer(token: String)
        case custom(headerField: String, headerValue: String)
        
        public var headerValue: String {
            switch self {
            case .basic(let username, let password):
                let pwd = password ?? ""
                guard let data = "\(username):\(pwd)".data(using: .utf8) else {
                    return ""
                }
                
                let base64 = data.base64EncodedString(options: [])
                
                return "Basic \(base64)"
            case .bearer(let token):
                return "Bearer \(token)"
            case .custom(let headerField, let headerValue):
                return "\(headerField) \(headerValue))"
            }
        }
    }
    
    /// General errors that may be emitted during HTTP Request/Response handling.
    public enum Error: Swift.Error, LocalizedError {
        case invalidURL
        case invalidRequest
        case invalidResponse
        
        public var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL: URL is nil or invalid."
            case .invalidRequest:
                return "Invalid URL Request: URLRequest is nil or invalid."
            case .invalidResponse:
                return "Invalid URL Response: HTTPURLResponse is nil or invalid."
            }
        }
    }
    
    /// A general completion handler for HTTP requests.
    public typealias DataTaskCompletion = (_ statusCode: Int, _ headers: Headers?, _ data: Data?, _ error: Swift.Error?) -> Void
}

public extension URLRequest {
    mutating func setValue(_ value: String, forHTTPHeader header: HTTP.Header) {
        self.setValue(value, forHTTPHeaderField: header.rawValue)
    }
    
    mutating func setValue(_ value: HTTP.MIMEType, forHTTPHeader header: HTTP.Header) {
        self.setValue(value.rawValue, forHTTPHeaderField: header.rawValue)
    }
}
