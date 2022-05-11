import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension URLSessionConfiguration {
    /// A `URLSessionConfiguration` which includes a `URLCache` and has the `.returnCacheDataElseLoad` policy applied.
    static func cachingElseLoad(
        memoryCapacity: URLCache.Capacity = .twentyFiveMB,
        diskCapacity: URLCache.Capacity = .twoHundredMB
    ) -> URLSessionConfiguration {
        let configuration: URLSessionConfiguration = .default
        configuration.urlCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity)
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        return configuration
    }
}
