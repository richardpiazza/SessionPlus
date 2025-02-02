import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Logging

/// A `Client` implementation that operates expecting all requests use _absolute_ urls.
open class AbsoluteURLSessionClient: Client {

    public var verboseLogging: Bool = false
    public let session: URLSession
    private let logger: Logger = .sessionPlus

    public init(sessionConfiguration: URLSessionConfiguration = .default, sessionDelegate: URLSessionDelegate? = nil) {
        session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
    }

    public func performRequest(_ request: any Request) async throws -> any Response {
        if verboseLogging {
            logger.debug("HTTP Request", metadata: request.verboseMetadata)
        } else {
            logger.trace("HTTP Request", metadata: request.metadata)
        }

        let urlRequest = try URLRequest(request: request)

        #if canImport(FoundationNetworking)
        let (data, urlResponse) = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<(Data, URLResponse), Error>) in
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
            body: data
        )

        if verboseLogging {
            logger.debug("HTTP Response", metadata: response.verboseMetadata)
        } else {
            logger.trace("HTTP Response", metadata: response.metadata)
        }

        return response
    }
}
