import Foundation
import Logging
import SessionPlus

open class EmulatedClient: Client {

    public struct EmulatedRequest: Request, Identifiable, Codable {

        enum CodingKeys: String, CodingKey {
            case address
            case method
            case headers
            case queryItems
            case body
        }

        public var address: Address
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
            address = request.address
            method = request.method
            headers = request.headers
            queryItems = request.queryItems
            body = request.body
        }
    }

    public struct NotFound: Error {}

    public typealias Cache = [EmulatedRequest.ID: Result<any Response, any Error>]

    @available(*, deprecated)
    public var verboseLogging: Bool {
        get { logLevel.value == .trace }
        set { setLogLevel(newValue ? .trace : .debug) }
    }

    public var responseCache: Cache
    private var logLevel: ProtectedState = ProtectedState()

    public init(responseCache: Cache = [:]) {
        self.responseCache = responseCache
    }

    public init(requestResponse: [(any Request, any Response)]) {
        responseCache = [:]
        for item in requestResponse {
            cache(response: item.1, for: item.0)
        }
    }

    public func cache(response: any Response, for request: any Request) {
        let emulatedRequest = EmulatedRequest(request)
        responseCache[emulatedRequest.id] = .success(response)
    }

    public func cache(error: any Error, for request: any Request) {
        let emulatedRequest = EmulatedRequest(request)
        responseCache[emulatedRequest.id] = .failure(error)
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
