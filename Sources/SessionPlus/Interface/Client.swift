import Foundation
import Logging

// TODO: `Sendable` Conformance
public protocol Client {
    @available(*, deprecated, message: "Direct state access should be avoided.")
    var verboseLogging: Bool { get set }

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
    func performRequest(_ request: any Request) async throws -> any Response
}

public extension Client {
    /// Performs a network `Request` and decodes the response to a known type.
    ///
    /// - parameters:
    ///   - request: The details of the request to perform.
    ///   - decoder: The `JSONDecoder` that should be used to deserialize the result data.
    /// - returns: The decoded `Response` value.
    func performRequest<Content>(
        _ request: any Request,
        using decoder: JSONDecoder = JSONDecoder(),
    ) async throws -> Content where Content: Decodable {
        let response = try await performRequest(request)
        return try decoder.decode(Content.self, from: response.body)
    }
}
