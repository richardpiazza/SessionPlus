import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A Collection of methods/headers/values/types used during basic HTTP interactions.
public struct HTTP {
    
    /// HTTP Header date formatter; RFC1123
    static var headerDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"
        formatter.timeZone = TimeZone(identifier: "GMT")!
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    /// HTTP Headers as provided from HTTPURLResponse
    public typealias Headers = [AnyHashable : Any]
    
    /// General errors that may be encountered during HTTP request/response handling.
    public enum Error: Swift.Error, LocalizedError {
        case invalidURL
        case invalidRequest
        case invalidResponse
        case undefined(Swift.Error?)
        
        public var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL: URL is nil or invalid."
            case .invalidRequest:
                return "Invalid URL Request: URLRequest is nil or invalid."
            case .invalidResponse:
                return "Invalid URL Response: HTTPURLResponse is nil or invalid."
            case .undefined(let error):
                return "Undefined Error: \(error?.localizedDescription ?? "")"
            }
        }
    }
    
    /// A general completion handler for HTTP requests.
    public typealias DataTaskCompletion = (_ statusCode: Int, _ headers: Headers?, _ data: Data?, _ error: Swift.Error?) -> Void
    
    #if swift(>=5.5) && canImport(ObjectiveC)
    /// The output of an async url request execution.
    public typealias AsyncDataTaskOutput = (statusCode: Int, headers: Headers, data: Data)
    #endif
}

// The HTTP.* name-spacing will be removed in future versions of SessionPlus.
public extension HTTP {
    @available(*, deprecated, renamed: "Authorization")
    typealias Authorization = SessionPlus.Authorization
    @available(*, deprecated, renamed: "Header")
    typealias Header = SessionPlus.Header
    @available(*, deprecated, renamed: "MIMEType")
    typealias MIMEType = SessionPlus.MIMEType
    @available(*, deprecated, renamed: "Method")
    typealias RequestMethod = Method
    @available(*, deprecated, renamed: "StatusCode")
    typealias StatusCode = SessionPlus.StatusCode
}
