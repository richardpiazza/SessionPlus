import Foundation
import Logging

public protocol Client {
    var verboseLogging: Bool { get set }

    /// Perform a network `Request`.
    ///
    /// - parameters:
    ///   - request: The details of the request to perform.
    /// - returns: The `Response` to the `Request`.
    func performRequest(_ request: any Request) async throws -> any Response
}

public extension Client {
    /// Performs a network `Request` and decodes the response to a known type.
    ///
    /// - parameters:
    ///   - request: The details of the request to perform.
    ///   - decoder: The `JSONDecoder` that should be used to deserialize the result data.
    /// - returns: The decoded `Response` value.
    func performRequest<Value>(_ request: any Request, using decoder: JSONDecoder = JSONDecoder()) async throws -> Value where Value: Decodable {
        let response = try await performRequest(request)
        return try decoder.decode(Value.self, from: response.body)
    }
}
