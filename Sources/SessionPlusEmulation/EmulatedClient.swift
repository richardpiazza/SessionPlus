import Foundation
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

        public init(_ request: Request) {
            address = request.address
            method = request.method
            headers = request.headers
            queryItems = request.queryItems
            body = request.body
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            address = try container.decode(Address.self, forKey: .address)
            method = try container.decode(Method.self, forKey: .method)
            headers = try container.decodeIfPresent([String: String].self, forKey: .headers)
            queryItems = try container.decodeIfPresent([QueryItem].self, forKey: .queryItems)
            body = try container.decodeIfPresent(Data.self, forKey: .body)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(address, forKey: .address)
            try container.encode(method, forKey: .method)
            try container.encodeIfPresent(headers as? [String: String], forKey: .headers)
            try container.encodeIfPresent(queryItems, forKey: .queryItems)
            try container.encodeIfPresent(body, forKey: .body)
        }
    }

    public struct NotFound: Error {}

    public typealias Cache = [EmulatedRequest.ID: Result<Response, Error>]

    public var verboseLogging: Bool = false
    public var responseCache: Cache

    public init(responseCache: Cache = [:]) {
        self.responseCache = responseCache
    }

    public init(requestResponse: [(Request, Response)]) {
        responseCache = [:]
        for item in requestResponse {
            cache(response: item.1, for: item.0)
        }
    }

    public func cache(response: Response, for request: Request) {
        let emulatedRequest = EmulatedRequest(request)
        responseCache[emulatedRequest.id] = .success(response)
    }

    public func cache(error: Error, for request: Request) {
        let emulatedRequest = EmulatedRequest(request)
        responseCache[emulatedRequest.id] = .failure(error)
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
