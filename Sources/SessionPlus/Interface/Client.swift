import Foundation
import Logging

public protocol Client: Sendable {
    /// Provides an `AsyncStream` with the clients `Logger.Level` state.
    var logLevelStream: AsyncStream<Logger.Level> { get }

    /// Requests an adjustment to the `Client` logging level.
    ///
    /// The client implementations provided by this package primarily observe
    /// `.trace`, `.debug`, & `.info`.
    func setLogLevel(_ level: Logger.Level)

    /// Perform a network `Request`.
    ///
    /// - parameters:
    ///   - request: The details of the request to perform.
    /// - returns: The `Response` to the `Request`.
    @concurrent func performRequest(_ request: any Request) async throws -> any Response
}

public extension Client {
    /// Performs a network `Request` and decodes the response to a known type.
    ///
    /// - parameters:
    ///   - request: The details of the request to perform.
    ///   - decoder: The `JSONDecoder` that should be used to deserialize the result data.
    /// - returns: The decoded `Response` value.
    @concurrent func performRequest<Content: Decodable>(
        _ request: any Request,
        using decoder: JSONDecoder = JSONDecoder(),
    ) async throws -> Content {
        let response = try await performRequest(request)
        return try decoder.decode(Content.self, from: response.body)
    }
}
