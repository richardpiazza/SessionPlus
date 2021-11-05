import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
#if canImport(UIKit)
import UIKit
#endif

@available(*, deprecated, renamed: "Downloader.DataCompletion")
public typealias DownloaderDataCompletion = Downloader.DataCompletion

/// A wrapper for `URLSession` similar to `WebAPI` for general purpose downloading of data and images.
open class Downloader {
    
    public typealias DataCompletion = (_ statusCode: Int, _ responseData: Data?, _ error: Error?) -> Void
    #if swift(>=5.5) && canImport(ObjectiveC)
    public typealias AsyncDataCompletion = (statusCode: Int, responseData: Data)
    #endif
    
    #if canImport(UIKit)
    public typealias ImageCompletion = (_ statusCode: Int, _ responseImage: UIImage?, _ error: Error?) -> Void
    #if swift(>=5.5)
    public typealias AsyncImageCompletion = (statusCode: Int, image: UIImage)
    #endif
    #endif
    
    fileprivate static let twentyFiveMB: Int = (1024 * 1024 * 25)
    fileprivate static let twoHundredMB: Int = (1024 * 1024 * 200)
    
    public enum Errors: Error {
        case invalidBaseURL
        case invalidResponseData
        
        public var localizedDescription: String {
            switch self {
            case .invalidBaseURL:
                return "Invalid Base URL: You can not use a `path` method without specifying a baseURL."
            case .invalidResponseData:
                return "Invalid Response Data: The response data was nil or failed to be decoded."
            }
        }
    }
    
    fileprivate lazy var session: URLSession = {
        [unowned self] in
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = self.cache
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
    }()
    #if canImport(FoundationNetworking)
    private let cache: URLCache = URLCache(memoryCapacity: Downloader.twentyFiveMB, diskCapacity: Downloader.twoHundredMB, diskPath: "Downloader")
    #else
    private let cache: URLCache = {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
            return URLCache(memoryCapacity: Downloader.twentyFiveMB, diskCapacity: Downloader.twoHundredMB)
        } else {
            #if targetEnvironment(macCatalyst)
            return URLCache(memoryCapacity: Downloader.twentyFiveMB, diskCapacity: Downloader.twoHundredMB)
            #else
            return URLCache(memoryCapacity: Downloader.twentyFiveMB, diskCapacity: Downloader.twoHundredMB, diskPath: "Downloader")
            #endif
        }
    }()
    #endif
    public var baseURL: URL?
    public var timeout: TimeInterval = 20
    
    public init() {
    }
    
    public convenience init(baseURL: URL) {
        self.init()
        self.baseURL = baseURL
    }
    
    internal func urlForPath(_ path: String) -> URL? {
        guard let baseURL = self.baseURL else {
            return nil
        }
        
        return baseURL.appendingPathComponent(path)
    }
    
    open func getDataAtURL(_ url: URL, cachePolicy: URLRequest.CachePolicy, completion: @escaping DataCompletion) {
        let request = NSMutableURLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
        request.httpMethod = HTTP.RequestMethod.get.rawValue
        
        let urlRequest: URLRequest = request as URLRequest

        session.dataTask(with: urlRequest, completionHandler: { (data, response, error) -> Void in
            #if canImport(ObjectiveC)
                DispatchQueue.main.async(execute: { () -> Void in
                    guard error == nil else {
                        completion(0, data, error)
                        return
                    }
                    
                    let httpResponse = response as! HTTPURLResponse
                    completion(httpResponse.statusCode, data, error)
                })
            #else
                guard error == nil else {
                    completion(0, data, error)
                    return
                }
                
                let httpResponse = response as! HTTPURLResponse
                completion(httpResponse.statusCode, data, error)
            #endif
        }) .resume()
    }
    
    open func getDataAtPath(_ path: String, cachePolicy: URLRequest.CachePolicy, completion: @escaping DataCompletion) {
        guard let url = self.urlForPath(path) else {
            completion(0, nil, Errors.invalidBaseURL)
            return
        }
        
        self.getDataAtURL(url, cachePolicy: cachePolicy, completion: completion)
    }
    
    #if swift(>=5.5) && canImport(ObjectiveC)
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    open func getDataAtURL(_ url: URL, cachePolicy: URLRequest.CachePolicy) async throws -> AsyncDataCompletion {
        let request = NSMutableURLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
        request.httpMethod = HTTP.RequestMethod.get.rawValue
        let urlRequest = request as URLRequest
        
        let sessionData = try await session.data(for: urlRequest)
        guard let httpResponse = sessionData.1 as? HTTPURLResponse else {
            throw HTTP.Error.invalidResponse
        }
        
        return (httpResponse.statusCode, sessionData.0)
    }
    
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    open func getDataAtPath(_ path: String, cachePolicy: URLRequest.CachePolicy) async throws -> AsyncDataCompletion {
        guard let url = self.urlForPath(path) else {
            throw Errors.invalidBaseURL
        }
        
        return try await getDataAtURL(url, cachePolicy: cachePolicy)
    }
    #endif
}

#if canImport(UIKit)
import UIKit

@available(*, deprecated, renamed: "Downloader.ImageCompletion")
public typealias DownloaderImageCompletion = Downloader.ImageCompletion

/// A wrapper for `URLSession` similar to `WebAPI` for general purpose downloading of data and images.
public extension Downloader {
    func getImageAtURL(_ url: URL, cachePolicy: URLRequest.CachePolicy, completion: @escaping ImageCompletion) {
        self.getDataAtURL(url, cachePolicy: cachePolicy) { (statusCode, responseData, error) -> Void in
            var image: UIImage?
            if responseData != nil {
                image = UIImage(data: responseData!)
            }
            
            completion(statusCode, image, error)
        }
    }
    
    func getImageAtPath(_ path: String, cachePolicy: URLRequest.CachePolicy, completion: @escaping ImageCompletion) {
        guard let url = self.urlForPath(path) else {
            completion(0, nil, Errors.invalidBaseURL)
            return
        }
        
        self.getImageAtURL(url, cachePolicy: cachePolicy, completion: completion)
    }
    
    #if swift(>=5.5)
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func getImageAtURL(_ url: URL, cachePolicy: URLRequest.CachePolicy) async throws -> AsyncImageCompletion {
        let response = try await getDataAtURL(url, cachePolicy: cachePolicy)
        guard let image = UIImage(data: response.responseData) else {
            throw Errors.invalidResponseData
        }
        return (response.statusCode, image)
    }
    
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func getImageAtPath(_ path: String, cachePolicy: URLRequest.CachePolicy) async throws -> AsyncImageCompletion {
        guard let url = self.urlForPath(path) else {
            throw Errors.invalidBaseURL
        }
        return try await getImageAtURL(url, cachePolicy: cachePolicy)
    }
    #endif
}
#endif
