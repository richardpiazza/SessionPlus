import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// The encapsulation of information needed to perform a request against an HTTP/REST service endpoint.
public protocol Request {
    /// Method used to address the request.
    var address: Address { get }
    /// The HTTP verb (action/method) associated with the request.
    var method: Method { get }
    /// Custom headers to provide in the created `URLRequest`.
    var headers: Headers? { get }
    /// Additional components that will be appended to the created `URL`.
    var queryItems: [URLQueryItem]? { get }
    /// Binary data that is attached to the `URLRequest`.
    var body: Data? { get }
}

public extension Request {
    /// Routing path extension.
    ///
    /// This is appended to a _base URL_ instance to create an 'absolute path' to a resource.
    var path: String {
        switch address {
        case .absolute(let url):
            return URLComponents(url: url, resolvingAgainstBaseURL: false)?.path ?? ""
        case .path(let path):
            return path
        }
    }
    
    /// Instructs the request to create an 'absolute' URL given a particular base/root `URL`.
    ///
    /// The default implementation appends the `path` and any `queryItems`.
    @available(*, deprecated, message: "URLRequest(request:baseUrl:) should be used directly.")
    func url(using baseURL: URL? = nil) throws -> URL {
        switch address {
        case .absolute(let url):
            return url
        case .path(let path):
            guard let baseURL = baseURL else {
                throw URLError(.badURL)
            }
            
            let pathUrl = baseURL.appendingPathComponent(path)
            
            guard let queryItems = self.queryItems else {
                return pathUrl
            }
            
            guard var components = URLComponents(url: pathUrl, resolvingAgainstBaseURL: false) else {
                throw URLError(.badURL)
            }
            
            components.queryItems = queryItems
            
            guard let url = components.url else {
                throw URLError(.badURL)
            }
            
            return url
        }
    }
    
    /// Appends (or overwrites) the **Authorization** key in the request headers.
    ///
    /// - parameters:
    ///   - token: The token which should be used for authentication.
    /// - returns: A modified `Request` that includes an authentication value.
    func authorized(_ authorization: Authorization) -> Request {
        var headers = self.headers ?? [:]
        headers[.authorization] = authorization.headerValue
        
        return AnyRequest(address: address, method: method, headers: headers, queryItems: queryItems, body: body)
    }
}
