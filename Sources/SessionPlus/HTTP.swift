import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A Collection of methods/headers/values/types used during basic HTTP interactions.
public struct HTTP {
    
    /// HTTP Headers as provided from HTTPURLResponse
    public typealias Headers = [AnyHashable : Any]
    
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
    
    #if swift(>=5.5)
    /// The output of an async url request execution.
    public typealias AsyncDataTaskOutput = (statusCode: Int, headers: Headers, data: Data)
    #endif
}

public extension URLRequest {
    mutating func setValue(_ value: String, forHTTPHeader header: HTTP.Header) {
        self.setValue(value, forHTTPHeaderField: header.rawValue)
    }
    
    mutating func setValue(_ value: HTTP.MIMEType, forHTTPHeader header: HTTP.Header) {
        self.setValue(value.rawValue, forHTTPHeaderField: header.rawValue)
    }
}
