import Foundation

open class EmulatedClient: Client {
    
    public struct EmulatedRequest: Request, Identifiable, Codable {
        
        enum CodingKeys: String, CodingKey {
            case path
            case method
            case headers
            case queryItems
            case body
        }
        
        public var path: String
        public var method: Method
        public var headers: Headers?
        public var queryItems: [URLQueryItem]?
        public var body: Data?
        
        public var id: String {
            guard let queryItems = self.queryItems else {
                return [method.description, path].joined(separator: " ")
            }
            
            let items = queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
            return [method.description, path, items].joined(separator: " ")
        }
        
        public init(_ request: Request) {
            path = request.path
            method = request.method
            headers = request.headers
            queryItems = request.queryItems
            body = request.body
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            path = try container.decode(String.self, forKey: .path)
            method = try container.decode(Method.self, forKey: .method)
            headers = try container.decodeIfPresent([String: String].self, forKey: .headers)
            queryItems = try container.decodeIfPresent([URLQueryItem].self, forKey: .queryItems)
            body = try container.decodeIfPresent(Data.self, forKey: .body)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(path, forKey: .path)
            try container.encode(method, forKey: .method)
            try container.encodeIfPresent(headers as? [String: String], forKey: .headers)
            try container.encodeIfPresent(queryItems, forKey: .queryItems)
            try container.encodeIfPresent(body, forKey: .body)
        }
    }
    
    public struct NotFound: Error {}
    
    public typealias Cache = [EmulatedRequest.ID: Result<Response, Error>]
    
    public var responseCache: Cache
    
    public init(responseCache: Cache = [:]) {
        self.responseCache = responseCache
    }
    
    public init(requestResponse: [(Request, Response)]) {
        self.responseCache = [:]
        requestResponse.forEach {
            cache(response: $0.1, for: $0.0)
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
    
    public func performRequest(_ request: Request, completion: @escaping (Result<Response, Error>) -> Void) {
        let id = EmulatedRequest(request).id
        guard let result = responseCache[id] else {
            completion(.failure(NotFound()))
            return
        }
        
        completion(result)
    }
}

extension URLQueryItem: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let value = try container.decodeIfPresent(String.self, forKey: .value)
        self.init(name: name, value: value)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(value, forKey: .value)
    }
}
