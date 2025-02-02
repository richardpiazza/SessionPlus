import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension URLCache {
    enum Capacity {
        case bytes(Int)
        case megabytes(Int)
        case gigabytes(Int)

        public static var twentyFiveMB: Capacity = .megabytes(25)
        public static var twoHundredMB: Capacity = .megabytes(200)

        public var bytes: Int {
            switch self {
            case .bytes(let value):
                value
            case .megabytes(let value):
                value * (1024 * 1024)
            case .gigabytes(let value):
                value * (1024 * 1024 * 1024)
            }
        }
    }

    convenience init(memoryCapacity: Capacity = .twentyFiveMB, diskCapacity: Capacity = .twoHundredMB) {
        #if canImport(FoundationNetworking)
        self.init(memoryCapacity: memoryCapacity.bytes, diskCapacity: diskCapacity.bytes, diskPath: "SessionPlusCache")
        #else
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
            self.init(memoryCapacity: memoryCapacity.bytes, diskCapacity: diskCapacity.bytes)
        } else {
            #if targetEnvironment(macCatalyst)
            self.init(memoryCapacity: memoryCapacity.bytes, diskCapacity: diskCapacity.bytes)
            #else
            self.init(memoryCapacity: memoryCapacity.bytes, diskCapacity: diskCapacity.bytes, diskPath: "SessionPlusCache")
            #endif
        }
        #endif
    }
}
