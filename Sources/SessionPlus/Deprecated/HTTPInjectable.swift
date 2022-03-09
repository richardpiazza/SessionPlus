import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Protocol used to extend an `HTTPClient` with support for injecting and retrieving canned responses.
@available(*, deprecated, message: "See 'Client' for more information.")
public protocol HTTPInjectable {
    var injectedResponses: [InjectedPath : InjectedResponse] { get set }
}

@available(*, deprecated, message: "See 'Client' for more information.")
public extension HTTPInjectable where Self: HTTPClient {
    func execute(request: URLRequest, completion: @escaping HTTP.DataTaskCompletion) {
        let injectedPath = InjectedPath(request: request)
        
        guard let injectedResponse = injectedResponses[injectedPath] else {
            completion(0, nil, nil, HTTP.Error.invalidResponse)
            return
        }
        
        #if canImport(ObjectiveC)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(injectedResponse.timeout * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
            switch injectedResponse.result {
            case .failure(let error):
                completion(injectedResponse.statusCode, injectedResponse.headers, nil, error)
            case .success(let data):
                completion(injectedResponse.statusCode, injectedResponse.headers, data, nil)
            }
        })
        #else
        let _ = Timer.scheduledTimer(withTimeInterval: TimeInterval(exactly: injectedResponse.timeout) ?? TimeInterval(floatLiteral: 0.0), repeats: false, block: { (timer) in
            switch injectedResponse.result {
            case .failure(let error):
                completion(injectedResponse.statusCode, injectedResponse.headers, nil, error)
            case .success(let data):
                completion(injectedResponse.statusCode, injectedResponse.headers, data, nil)
            }
        })
        #endif
    }
}

#if swift(>=5.5) && canImport(ObjectiveC)
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
@available(*, deprecated, message: "See 'Client' for more information.")
public extension HTTPInjectable where Self: HTTPClient {
    func execute(request: URLRequest) async throws -> HTTP.AsyncDataTaskOutput {
        let injectedPath = InjectedPath(request: request)
        guard let injectedResponse = injectedResponses[injectedPath] else {
            throw HTTP.Error.invalidResponse
        }
        
        try await Task.sleep(nanoseconds: injectedResponse.timeout * 1000000000)
        switch injectedResponse.result {
        case .failure(let error):
            throw error
        case .success(let data):
            return (injectedResponse.statusCode, injectedResponse.headers ?? [:], data)
        }
    }
}
#endif

/// A Hashable compound type based on the method and absolute path of a URLRequest.
@available(*, deprecated, message: "See 'EmulatedClient.EmulatedResponse' for more information.")
public struct InjectedPath: Hashable {
    var method: HTTP.RequestMethod = .get
    var absolutePath: String
    
    public init(request: URLRequest) {
        let method = HTTP.RequestMethod(stringLiteral: request.httpMethod ?? HTTP.RequestMethod.get.rawValue)
        let path = request.url?.absoluteString ?? ""
        self.init(method: method, absolutePath: path)
    }
    
    public init(method: HTTP.RequestMethod = .get, absolutePath: String) {
        self.method = method
        self.absolutePath = absolutePath
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine("\(method.rawValue)\(absolutePath)")
    }
    
    public static func ==(lhs: InjectedPath, rhs: InjectedPath) -> Bool {
        guard lhs.method == rhs.method else {
            return false
        }
        
        guard lhs.absolutePath == rhs.absolutePath else {
            return false
        }
        
        return true
    }
}

/// A response to provide for a pre-determined request.
@available(*, deprecated, message: "See 'EmulatedClient.EmulatedResponse' for more information.")
public struct InjectedResponse {
    public var statusCode: Int = 0
    public var headers: HTTP.Headers? = nil
    public var timeout: UInt64 = 0
    public var result: Result<Data, Error> = .failure(HTTP.Error.invalidResponse)
    
    public init() {
    }
    
    public init(statusCode: Int, headers: HTTP.Headers? = nil, timeout: UInt64 = 0, result: Result<Data, Error>) {
        self.statusCode = statusCode
        self.headers = headers
        self.timeout = timeout
        self.result = result
    }
}
