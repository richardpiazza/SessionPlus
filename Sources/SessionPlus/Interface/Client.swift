import Foundation
#if canImport(Combine)
import Combine
#endif

public protocol Client {
    #if swift(>=5.5.2)
    /// Perform a network `Request`.
    ///
    /// - parameters:
    ///   - request: The details of the request to perform.
    /// - returns: The `Response` to the `Request`.
    func performRequest(_ request: Request) async throws -> Response
    #endif
    
    #if canImport(Combine)
    /// Perform a network `Request`.
    ///
    /// - parameters:
    ///   - request: The details of the request to perform.
    /// - returns: Publisher that emits the `Response` to the `Request`.
    func performRequest(_ request: Request) -> AnyPublisher<Response, Error>
    #endif
    
    /// Perform a network `Request`.
    ///
    /// - parameters:
    ///   - request: The details of the request to perform.
    ///   - completion: Function called with the result of the request.
    func performRequest(_ request: Request, completion: @escaping (Result<Response, Error>) -> Void)
}

public extension Client {
    #if swift(>=5.5.2)
    /// Default implementation that uses the `withCheckedThrowingContinuation` api to call the `performRequest(_:)` method.
    func performRequest(_ request: Request) async throws -> Response {
        try await withCheckedThrowingContinuation({ continuation in
            performRequest(request) { result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                case .success(let response):
                    continuation.resume(returning: response)
                }
            }
        })
    }
    #endif
    
    #if canImport(Combine)
    /// Default implementation that wraps `performRequest(_:)` in a `Future`.
    func performRequest(_ request: Request) -> AnyPublisher<Response, Error> {
        Future { promise in
            performRequest(request) { result in
                switch result {
                case .failure(let error):
                    promise(.failure(error))
                case .success(let response):
                    promise(.success(response))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    #endif
}
