import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// The essential components of a HTTP/REST/JSON Client.
///
/// This protocol expresses a lightweight wrapper around Foundations `URLSession` for interacting with JSON REST API's.
public protocol HTTPClient {
    
    /// The root URL used to construct all queries.
    var baseURL: URL { get }
    
    /// The `URLSession` used to create tasks.
    var session: URLSession { get set }
    
    /// Auth credentials to provide in the request headers.
    var authorization: HTTP.Authorization? { get set }
    
    /// Constructs the request, setting the method, body data, and headers
    /// based on parameters specified.
    func request(method: HTTP.RequestMethod, path: String, queryItems: [URLQueryItem]?, data: Data?) throws -> URLRequest
    
    /// Creates a URLSessionDataTask using the URLSession.
    /// Allows access to the un-started task, useful for background execution.
    func task(request: URLRequest, completion: @escaping HTTP.DataTaskCompletion) throws -> URLSessionDataTask
    
    /// Executes the specified request.
    /// Gets the task from `task(request:completion:)` and calls `.resume()`.
    func execute(request: URLRequest, completion: @escaping HTTP.DataTaskCompletion)
    
    #if swift(>=5.5)
    /// Executes a `URLRequest`
    ///
    /// Uses the `async` concurrency apis to execute a `URLRequest` and return the result.
    ///
    /// - parameters:
    ///    - request: The `URLRequest` to execute
    /// - returns: Async data output
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func execute(request: URLRequest) async throws -> HTTP.AsyncDataTaskOutput
    #endif
}

public extension HTTPClient {
    func request(method: HTTP.RequestMethod, path: String, queryItems: [URLQueryItem]?, data: Data?) throws -> URLRequest {
        let pathURL = baseURL.appendingPathComponent(path)
        
        var urlComponents = URLComponents(url: pathURL, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            throw HTTP.Error.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let data = data {
            request.httpBody = data
            request.setValue("\(data.count)", forHTTPHeader: HTTP.Header.contentLength)
        }
        request.setValue(HTTP.Header.dateFormatter.string(from: Date()), forHTTPHeader: HTTP.Header.date)
        request.setValue(HTTP.MIMEType.json, forHTTPHeader: HTTP.Header.accept)
        request.setValue(HTTP.MIMEType.json, forHTTPHeader: HTTP.Header.contentType)
        
        if let authorization = self.authorization {
            request.setValue(authorization.headerValue, forHTTPHeader: HTTP.Header.authorization)
        }
        
        return request
    }
    
    func task(request: URLRequest, completion: @escaping HTTP.DataTaskCompletion) throws -> URLSessionDataTask {
        guard request.url != nil else {
            throw HTTP.Error.invalidURL
        }
        
        return session.dataTask(with: request) { (responseData, urlResponse, error) in
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                completion(0, nil, responseData, error ?? HTTP.Error.invalidResponse)
                return
            }
            
            completion(httpResponse.statusCode, httpResponse.allHeaderFields, responseData, error)
        }
    }
    
    func execute(request: URLRequest, completion: @escaping HTTP.DataTaskCompletion) {
        let task: URLSessionDataTask
        do {
            task = try self.task(request: request, completion: completion)
        } catch {
            completion(0, nil, nil, error)
            return
        }
        
        task.resume()
    }
    
    /// Convenience method for generating and executing a request using the `GET` http method.
    func get(_ path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping HTTP.DataTaskCompletion) {
        do {
            let request = try self.request(method: .get, path: path, queryItems: queryItems, data: nil)
            self.execute(request: request, completion: completion)
        } catch {
            completion(0, nil, nil, error)
        }
    }
    
    /// Convenience method for generating and executing a request using the `PUT` http method.
    func put(_ data: Data?, path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping HTTP.DataTaskCompletion) {
        do {
            let request = try self.request(method: .put, path: path, queryItems: queryItems, data: data)
            self.execute(request: request, completion: completion)
        } catch {
            completion(0, nil, nil, error)
        }
    }
    
    /// Convenience method for generating and executing a request using the `POST` http method.
    func post(_ data: Data?, path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping HTTP.DataTaskCompletion) {
        do {
            let request = try self.request(method: .post, path: path, queryItems: queryItems, data: data)
            self.execute(request: request, completion: completion)
        } catch {
            completion(0, nil, nil, error)
        }
    }
    
    /// Convenience method for generating and executing a request using the `PATCH` http method.
    func patch(_ data: Data?, path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping HTTP.DataTaskCompletion) {
        do {
            let request = try self.request(method: .patch, path: path, queryItems: queryItems, data: data)
            self.execute(request: request, completion: completion)
        } catch {
            completion(0, nil, nil, error)
        }
    }
    
    /// Convenience method for generating and executing a request using the `DELETE` http method.
    func delete(_ path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping HTTP.DataTaskCompletion) {
        do {
            let request = try self.request(method: .delete, path: path, queryItems: queryItems, data: nil)
            self.execute(request: request, completion: completion)
        } catch {
            completion(0, nil, nil, error)
        }
    }
}

#if swift(>=5.5)
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension HTTPClient {
    func execute(request: URLRequest) async throws -> HTTP.AsyncDataTaskOutput {
        let sessionData = try await session.data(for: request)
        
        guard let httpResponse = sessionData.1 as? HTTPURLResponse else {
            throw HTTP.Error.invalidResponse
        }
        
        return (httpResponse.statusCode, httpResponse.allHeaderFields, sessionData.0)
    }
    
    /// Convenience method for performing a `GET` request.
    ///
    /// This method first creates a `URLRequest` using the `request(method:path:queryItems:data:)` method. Then it passes the
    /// request as a parameter to the `async` `execute(request:)` method.
    ///
    /// - parameters:
    ///   - path: Component path extension that is appended to the `baseURL`.
    ///   - queryItems: Key/Value components added to the request `URL`.
    /// - returns: Awaited response data output
    func get(_ path: String, queryItems: [URLQueryItem]? = nil) async throws -> HTTP.AsyncDataTaskOutput {
        let request = try self.request(method: .get, path: path, queryItems: queryItems, data: nil)
        return try await execute(request: request)
    }
    
    /// Convenience method for performing a `PUT` request.
    ///
    /// This method first creates a `URLRequest` using the `request(method:path:queryItems:data:)` method. Then it passes the
    /// request as a parameter to the `async` `execute(request:)` method.
    ///
    /// - parameters:
    ///   - data: Data that should be presented as the `URLRequest` body.
    ///   - path: Component path extension that is appended to the `baseURL`.
    ///   - queryItems: Key/Value components added to the request `URL`.
    /// - returns: Awaited response data output
    func put(_ data: Data?, path: String, queryItems: [URLQueryItem]? = nil) async throws -> HTTP.AsyncDataTaskOutput {
        let request = try self.request(method: .put, path: path, queryItems: queryItems, data: data)
        return try await execute(request: request)
    }
    
    /// Convenience method for performing a `POST` request.
    ///
    /// This method first creates a `URLRequest` using the `request(method:path:queryItems:data:)` method. Then it passes the
    /// request as a parameter to the `async` `execute(request:)` method.
    ///
    /// - parameters:
    ///   - data: Data that should be presented as the `URLRequest` body.
    ///   - path: Component path extension that is appended to the `baseURL`.
    ///   - queryItems: Key/Value components added to the request `URL`.
    /// - returns: Awaited response data output
    func post(_ data: Data?, path: String, queryItems: [URLQueryItem]? = nil) async throws -> HTTP.AsyncDataTaskOutput {
        let request = try self.request(method: .post, path: path, queryItems: queryItems, data: data)
        return try await execute(request: request)
    }
    
    /// Convenience method for performing a `PATCH` request.
    ///
    /// This method first creates a `URLRequest` using the `request(method:path:queryItems:data:)` method. Then it passes the
    /// request as a parameter to the `async` `execute(request:)` method.
    ///
    /// - parameters:
    ///   - data: Data that should be presented as the `URLRequest` body.
    ///   - path: Component path extension that is appended to the `baseURL`.
    ///   - queryItems: Key/Value components added to the request `URL`.
    /// - returns: Awaited response data output
    func patch(_ data: Data?, path: String, queryItems: [URLQueryItem]? = nil) async throws -> HTTP.AsyncDataTaskOutput {
        let request = try self.request(method: .patch, path: path, queryItems: queryItems, data: data)
        return try await execute(request: request)
    }
    
    /// Convenience method for performing a `DELETE` request.
    ///
    /// This method first creates a `URLRequest` using the `request(method:path:queryItems:data:)` method. Then it passes the
    /// request as a parameter to the `async` `execute(request:)` method.
    ///
    /// - parameters:
    ///   - path: Component path extension that is appended to the `baseURL`.
    ///   - queryItems: Key/Value components added to the request `URL`.
    /// - returns: Awaited response data output
    func delete(_ path: String, queryItems: [URLQueryItem]? = nil) async throws -> HTTP.AsyncDataTaskOutput {
        let request = try self.request(method: .delete, path: path, queryItems: queryItems, data: nil)
        return try await execute(request: request)
    }
}
#endif
