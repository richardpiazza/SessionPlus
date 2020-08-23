import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public typealias DownloaderDataCompletion = (_ statusCode: Int, _ responseData: Data?, _ error: Error?) -> Void

/// A wrapper for `URLSession` similar to `WebAPI` for general purpose downloading of data and images.
open class Downloader {
    fileprivate static let twentyFiveMB: Int = (1024 * 1024 * 25)
    fileprivate static let twoHundredMB: Int = (1024 * 1024 * 200)
    
    public enum Errors: Error {
        case invalidBaseURL
        
        public var localizedDescription: String {
            return "Invalid Base URL: You can not use a `path` method without specifying a baseURL."
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
    
    open func getDataAtPath(_ path: String, cachePolicy: URLRequest.CachePolicy, completion: @escaping DownloaderDataCompletion) {
        guard let url = self.urlForPath(path) else {
            completion(0, nil, Errors.invalidBaseURL)
            return
        }
        
        self.getDataAtURL(url, cachePolicy: cachePolicy, completion: completion)
    }
    
    open func getDataAtURL(_ url: URL, cachePolicy: URLRequest.CachePolicy, completion: @escaping DownloaderDataCompletion) {
        let request = NSMutableURLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
        request.httpMethod = "GET"
        
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
}

#if (os(iOS) || os(tvOS))
import UIKit

public typealias DownloaderImageCompletion = (_ statusCode: Int, _ responseImage: UIImage?, _ error: Error?) -> Void

/// A wrapper for `URLSession` similar to `WebAPI` for general purpose downloading of data and images.
public extension Downloader {
    func getImageAtPath(_ path: String, cachePolicy: URLRequest.CachePolicy, completion: @escaping DownloaderImageCompletion) {
        guard let url = self.urlForPath(path) else {
            completion(0, nil, Errors.invalidBaseURL)
            return
        }
        
        self.getImageAtURL(url, cachePolicy: cachePolicy, completion: completion)
    }
    
    func getImageAtURL(_ url: URL, cachePolicy: URLRequest.CachePolicy, completion: @escaping DownloaderImageCompletion) {
        self.getDataAtURL(url, cachePolicy: cachePolicy) { (statusCode, responseData, error) -> Void in
            var image: UIImage?
            if responseData != nil {
                image = UIImage(data: responseData!)
            }
            
            completion(statusCode, image, error)
        }
    }
}
#endif
