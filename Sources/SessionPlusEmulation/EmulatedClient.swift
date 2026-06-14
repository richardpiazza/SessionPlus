import Foundation
import Logging
import Mutex
import SessionPlus

public final class EmulatedClient: Client {

    public struct EmulatedRequest: Request, Identifiable, Codable {

        enum CodingKeys: String, CodingKey {
            case resource
            case method
            case headers
            case queryItems
            case body
        }

        public var resource: Resource
        public var method: SessionPlus.Method
        public var headers: Headers?
        public var queryItems: [QueryItem]?
        public var body: Data?

        public var id: String {
            guard let queryItems else {
                return [method.description, path].joined(separator: " ")
            }

            let items = queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
            return [method.description, path, items].joined(separator: " ")
        }

        public init(_ request: any Request) {
            resource = request.resource
            method = request.method
            headers = request.headers
            queryItems = request.queryItems
            body = request.body
        }
    }

    public struct NotFound: Error {}

    public typealias Cache = [EmulatedRequest.ID: Result<any Response, any Error>]

    public var responseCache: Cache {
        cache.withLock { $0 }
    }

    private let logLevel: ProtectedState<Logger.Level> = ProtectedState(.trace)
    private let cache: Mutex<Cache>

    public init(responseCache: Cache = [:]) {
        cache = Mutex(responseCache)
    }

    public init(requestResponse: [(any Request, any Response)]) {
        cache = Mutex([:])
        for item in requestResponse {
            cache(response: item.1, for: item.0)
        }
    }

    public func cache(response: any Response, for request: any Request) {
        let emulatedRequest = EmulatedRequest(request)
        cache.withLock {
            $0[emulatedRequest.id] = .success(response)
        }
    }

    public func cache(error: any Error, for request: any Request) {
        let emulatedRequest = EmulatedRequest(request)
        cache.withLock {
            $0[emulatedRequest.id] = .failure(error)
        }
    }

    public var logLevelStream: AsyncStream<Logger.Level> {
        logLevel.asyncStream
    }

    public func setLogLevel(_ level: Logger.Level) {
        logLevel.setValue(level)
    }

    public func performRequest(_ request: any Request) async throws -> any Response {
        let id = EmulatedRequest(request).id
        guard let result = responseCache[id] else {
            throw NotFound()
        }

        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}
