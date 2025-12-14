import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Logging

/// A `Client` implementation that operates with a _base_ URL which all requests use to form the address.
open class BaseURLSessionClient: Client {

    @available(*, deprecated)
    public var verboseLogging: Bool {
        get { logLevel.value == .trace }
        set { setLogLevel(newValue ? .trace : .debug) }
    }

    open var baseURL: URL
    public let session: URLSession
    private let logger: Logger = .sessionPlus
    private let logLevel: ProtectedState = ProtectedState()

    public init(
        baseURL: URL,
        sessionConfiguration: URLSessionConfiguration = .default,
        sessionDelegate: (any URLSessionDelegate)? = nil,
    ) {
        self.baseURL = baseURL
        session = URLSession(
            configuration: sessionConfiguration,
            delegate: sessionDelegate,
            delegateQueue: nil,
        )
    }

    public var logLevelStream: AsyncStream<Logger.Level> {
        logLevel.asyncStream
    }

    public func setLogLevel(_ level: Logger.Level) {
        logLevel.setValue(level)
    }

    public func performRequest(_ request: any Request) async throws -> any Response {
        if logLevel.value > .trace {
            logger.debug("HTTP Request", metadata: request.verboseMetadata)
        } else {
            logger.trace("HTTP Request", metadata: request.metadata)
        }

        let urlRequest = try URLRequest(request: request, baseUrl: baseURL)

        #if canImport(FoundationNetworking)
        let (data, urlResponse) = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<(Data, URLResponse), any Error>) in
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
        let (data, urlResponse) = try await session.data(for: urlRequest)
        #endif

        let response = AnyResponse(
            statusCode: urlResponse.statusCode,
            headers: urlResponse.headers,
            body: data,
        )

        if logLevel.value > .trace {
            logger.debug("HTTP Response", metadata: response.verboseMetadata)
        } else {
            logger.trace("HTTP Response", metadata: response.metadata)
        }

        return response
    }
}
