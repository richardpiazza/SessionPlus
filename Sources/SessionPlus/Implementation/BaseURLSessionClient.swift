import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
#if canImport(Combine)
import Combine
#endif

/// A `Client` implementation that operates with a _base_ URL which all requests use to form the address.
open class BaseURLSessionClient: Client {
    
    open var baseURL: URL
    public let session: URLSession
    
    public init(baseURL: URL, sessionConfiguration: URLSessionConfiguration = .default, sessionDelegate: URLSessionDelegate? = nil) {
        self.baseURL = baseURL
        self.session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
    }
    
    #if (os(macOS) || os(iOS) || os(tvOS) || os(watchOS))
    /// Implementation that uses the `URLSession` async/await concurrency apis for handling a `Request`/`Response` interaction.
    ///
    /// The `URLSession` api is only available on Apple platforms, as the `FoundationNetworking` version has not been updated.
    public func performRequest(_ request: Request) async throws -> Response {
        let urlRequest = try URLRequest(request: request, baseUrl: baseURL)
        let sessionResponse = try await session.data(for: urlRequest)
        return AnyResponse(statusCode: sessionResponse.1.statusCode, headers: sessionResponse.1.headers, data: sessionResponse.0)
    }
    #endif
    
    #if canImport(Combine)
    /// Implementation that uses the `URLSession.DataTaskPublisher` to handle the `Request`/`Response` interaction.
    public func performRequest(_ request: Request) -> AnyPublisher<Response, Error> {
        let urlRequest: URLRequest
        do {
            urlRequest = try URLRequest(request: request, baseUrl: baseURL)
        } catch {
            return Fail(outputType: Response.self, failure: error).eraseToAnyPublisher()
        }
        
        return session
            .dataTaskPublisher(for: urlRequest)
            .tryMap { taskResponse -> Response in
                AnyResponse(statusCode: taskResponse.response.statusCode, headers: taskResponse.response.headers, data: taskResponse.data)
            }
            .eraseToAnyPublisher()
    }
    #endif
    
    /// Implementation that uses the default `URLSessionDataTask` methods for handling a `Request`/`Response` interaction.
    public func performRequest(_ request: Request, completion: @escaping (Result<Response, Error>) -> Void) {
        let urlRequest: URLRequest
        do {
            urlRequest = try URLRequest(request: request, baseUrl: baseURL)
        } catch {
            completion(.failure(error))
            return
        }
        
        session.dataTask(with: urlRequest) { data, urlResponse, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let httpResponse = urlResponse else {
                completion(.failure(URLError(.cannotParseResponse)))
                return
            }
            
            let response = AnyResponse(statusCode: httpResponse.statusCode, headers: httpResponse.headers, data: data ?? Data())
            completion(.success(response))
        }
        .resume()
    }
}
