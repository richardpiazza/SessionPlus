import Foundation
#if canImport(Combine)
import Combine
#endif

public extension Client {
    #if swift(>=5.5.2)
    /// Performs a network `Request` and decodes the response to a known type.
    ///
    /// - parameters:
    ///   - request: The details of the request to perform.
    ///   - decoder: The `JSONDecoder` that should be used to deserialize the result data.
    /// - returns: The decoded `Response` value.
    func performRequest<Value>(_ request: Request, using decoder: JSONDecoder = JSONDecoder()) async throws -> Value where Value: Decodable {
        let response = try await performRequest(request)
        return try decoder.decode(Value.self, from: response.data)
    }
    #endif
    
    #if canImport(Combine)
    /// Performs a network `Request` and decodes the response to a known type.
    ///
    /// - parameters:
    ///   - request: The details of the request to perform.
    ///   - decoder: The `JSONDecoder` that should be used to deserialize the result data.
    /// - returns: Publisher that emits the decoded value result of the request.
    func performRequest<Value>(_ request: Request, using decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Value, Error> where Value: Decodable {
        performRequest(request)
            .map { $0.data }
            .decode(type: Value.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    #endif
    
    /// Performs a network `Request` and decodes the response to a known type.
    ///
    /// - parameters:
    ///   - request: The details of the request to perform.
    ///   - decoder: The `JSONDecoder` that should be used to deserialize the result data.
    ///   - completion: Function called with the result of the request.
    func performRequest<Value>(_ request: Request, using decoder: JSONDecoder = JSONDecoder(), completion: @escaping (Result<Value, Error>) -> Void) where Value: Decodable {
        performRequest(request) { (result: Result<Response, Error>) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let response):
                do {
                    let value = try decoder.decode(Value.self, from: response.data)
                    completion(.success(value))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}
