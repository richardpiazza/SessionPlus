import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension HTTP {
    typealias CodableTaskCompletion<D: Decodable> = (_ statusCode: Int, _ headers: Headers?, _ data: D?, _ error: Swift.Error?) -> Void
    #if swift(>=5.5)
    typealias AsyncCodableTaskOutput<D: Decodable> = (statusCode: Int, headers: Headers, data: D)
    #endif
}

/// Protocol used to extend an `HTTPClient` with support for automatic encoding and decoding or request and response
/// data.
public protocol HTTPCodable {
    var jsonEncoder: JSONEncoder { get set }
    var jsonDecoder: JSONDecoder { get set }
}

public extension HTTPCodable where Self: HTTPClient {
    func encode<E: Encodable>(_ encodable: E?) throws -> Data? {
        var data: Data? = nil
        if let encodable = encodable {
            data = try jsonEncoder.encode(encodable)
        }
        return data
    }
    
    func decode<D: Decodable>(statusCode: Int, headers: HTTP.Headers?, data: Data?, error: Swift.Error?, completion: @escaping HTTP.CodableTaskCompletion<D>) {
        guard let data = data else {
            completion(statusCode, headers, nil, error)
            return
        }
        
        let result: D
        do {
            result = try jsonDecoder.decode(D.self, from: data)
            completion(statusCode, headers, result, nil)
        } catch let decoderError {
            completion(statusCode, headers, nil, decoderError)
        }
    }
    
    func get<D: Decodable>(_ path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping HTTP.CodableTaskCompletion<D>) {
        self.get(path, queryItems: queryItems) { (statusCode, headers, data: Data?, error) in
            self.decode(statusCode: statusCode, headers: headers, data: data, error: error, completion: completion)
        }
    }
    
    func put<E: Encodable, D: Decodable>(_ encodable: E?, path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping HTTP.CodableTaskCompletion<D>) {
        var data: Data? = nil
        do {
            data = try self.encode(encodable)
        } catch {
            completion(0, nil, nil, error)
            return
        }
        
        self.put(data, path: path, queryItems: queryItems) { (statusCode, headers, data: Data?, error) in
            self.decode(statusCode: statusCode, headers: headers, data: data, error: error, completion: completion)
        }
    }
    
    func post<E: Encodable, D: Decodable>(_ encodable: E?, path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping HTTP.CodableTaskCompletion<D>) {
        var data: Data? = nil
        do {
            data = try self.encode(encodable)
        } catch {
            completion(0, nil, nil, error)
            return
        }
        
        self.post(data, path: path, queryItems: queryItems) { (statusCode, headers, data: Data?, error) in
            self.decode(statusCode: statusCode, headers: headers, data: data, error: error, completion: completion)
        }
    }
    
    func post<D: Decodable>(_ data: Data?, path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping HTTP.CodableTaskCompletion<D>) {
        self.post(data, path: path, queryItems: queryItems) { (statusCode, headers, data: Data?, error) in
            self.decode(statusCode: statusCode, headers: headers, data: data, error: error, completion: completion)
        }
    }
    
    func patch<E: Encodable, D: Decodable>(_ encodable: E?, path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping HTTP.CodableTaskCompletion<D>) {
        var data: Data? = nil
        do {
            data = try self.encode(encodable)
        } catch {
            completion(0, nil, nil, error)
            return
        }
        
        self.patch(data, path: path, queryItems: queryItems) { (statusCode, headers, data: Data?, error) in
            self.decode(statusCode: statusCode, headers: headers, data: data, error: error, completion: completion)
        }
    }
    
    func delete<D: Decodable>(_ path: String, queryItems: [URLQueryItem]? = nil, completion: @escaping HTTP.CodableTaskCompletion<D>) {
        self.delete(path, queryItems: queryItems) { (statusCode, headers, data: Data?, error) in
            self.decode(statusCode: statusCode, headers: headers, data: data, error: error, completion: completion)
        }
    }
}

#if swift(>=5.5)
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension HTTPCodable where Self: HTTPClient {
    func decode<D: Decodable>(response: HTTP.AsyncDataTaskOutput) throws -> HTTP.AsyncCodableTaskOutput<D> {
        let result = try jsonDecoder.decode(D.self, from: response.data)
        return (response.statusCode, response.headers, result)
    }
    
    func get<D: Decodable>(_ path: String, queryItems: [URLQueryItem]? = nil) async throws -> HTTP.AsyncCodableTaskOutput<D> {
        let response = try await self.get(path, queryItems: queryItems)
        return try decode(response: response)
    }
    
    func put<E: Encodable, D: Decodable>(_ encodable: E?, path: String, queryItems: [URLQueryItem]? = nil) async throws -> HTTP.AsyncCodableTaskOutput<D> {
        let data = try encode(encodable)
        let response = try await self.put(data, path: path, queryItems: queryItems)
        return try decode(response: response)
    }
    
    func post<E: Encodable, D: Decodable>(_ encodable: E?, path: String, queryItems: [URLQueryItem]? = nil) async throws -> HTTP.AsyncCodableTaskOutput<D> {
        let data = try encode(encodable)
        let response = try await self.post(data, path: path, queryItems: queryItems)
        return try decode(response: response)
    }
    
    func post<D: Decodable>(_ data: Data?, path: String, queryItems: [URLQueryItem]? = nil) async throws -> HTTP.AsyncCodableTaskOutput<D> {
        let response = try await self.post(data, path: path, queryItems: queryItems)
        return try decode(response: response)
    }
    
    func patch<E: Encodable, D: Decodable>(_ encodable: E?, path: String, queryItems: [URLQueryItem]? = nil) async throws -> HTTP.AsyncCodableTaskOutput<D> {
        let data = try encode(encodable)
        let response = try await self.patch(data, path: path, queryItems: queryItems)
        return try decode(response: response)
    }
    
    func delete<D: Decodable>(_ path: String, queryItems: [URLQueryItem]? = nil) async throws -> HTTP.AsyncCodableTaskOutput<D> {
        let response = try await self.delete(path, queryItems: queryItems)
        return try decode(response: response)
    }
}
#endif
