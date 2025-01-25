import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A `Client` implementation that operates expecting all requests use _absolute_ urls.
open class AbsoluteURLSessionClient: Client {
    
    public let session: URLSession
    
    public init(sessionConfiguration: URLSessionConfiguration = .default, sessionDelegate: URLSessionDelegate? = nil) {
        self.session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
    }
    
    public func performRequest(_ request: any Request) async throws -> any Response {
        let urlRequest = try URLRequest(request: request)
        
        #if canImport(FoundationNetworking)
        let sessionResponse = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<(Data, URLResponse), Error>) in
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
