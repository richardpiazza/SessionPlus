import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// The encapsulation of information needed to perform a request against an HTTP/REST service endpoint.
public protocol Request {
    /// Routing path extension.
    ///
    /// This is appended to a _base URL_ instance to create an 'absolute path' to a resource.
    var path: String { get }
    /// The HTTP verb (action/method) associated with the request.
    var method: Method { get }
    /// Custom headers to provide in the created `URLRequest`.
    var headers: Headers? { get }
    /// Additional components that will be appended to the created `URL`.
    var queryItems: [URLQueryItem]? { get }
    /// Binary data that is attached to the `URLRequest`.
    var body: Data? { get }
    
    /// Instructs the request to create an 'absolute' URL given a particular base/root `URL`.
    ///
    /// The default implementation appends the `path` and any `queryItems`.
    func url(using baseURL: URL) throws -> URL
}

public extension Request {
    func url(using baseURL: URL) throws -> URL {
        let pathUrl = baseURL.appendingPathComponent(path)
        
        guard let queryItems = self.queryItems else {
            return pathUrl
        }
        
        guard var components = URLComponents(url: pathUrl, resolvingAgainstBaseURL: false) else {
            throw HTTP.Error.invalidURL
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw HTTP.Error.invalidURL
        }
        
        return url
    }
    
    /// Appends (or overwrites) the **Authorization** key in the request headers.
    ///
    /// - parameters:
    ///   - token: The token which should be used for authentication.
    /// - returns: A modified `Request` that includes an authentication value.
    func authorized(_ authorization: Authorization) -> Request {
        var headers = self.headers ?? [:]
        headers[.authorization] = authorization.headerValue
        
        return AnyRequest(path: path, method: method, headers: headers, queryItems: queryItems, body: body)
    }
}
