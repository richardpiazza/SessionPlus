import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A `Client` implementation that operates with a _base_ URL which all requests use to form the address.
open class BaseURLSessionClient: Client {
    
    open var baseURL: URL
    public let session: URLSession
    
    public init(baseURL: URL, sessionConfiguration: URLSessionConfiguration = .default, sessionDelegate: URLSessionDelegate? = nil) {
        self.baseURL = baseURL
        self.session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
    }
    
    public func performRequest(_ request: any Request) async throws -> any Response {
        let urlRequest = try URLRequest(request: request, baseUrl: baseURL)
        
        #if canImport(FoundationNetworking)
        let sessionResponse = try await withCheckedThrowingContinuation { continuation in
            session.dataTask(with: urlRequest) { data, urlResponse, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: (data!, urlResponse!))
            }
            .resume()
        }
        #else
        let sessionResponse = try await session.data(for: urlRequest)
        #endif
        
        let response = AnyResponse(
            statusCode: sessionResponse.1.statusCode,
            headers: sessionResponse.1.headers,
            data: sessionResponse.0
        )
        
        return response
    }
}
