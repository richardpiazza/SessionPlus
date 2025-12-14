import Foundation
import Logging

public typealias Headers = [String: String]

public extension Headers {
    subscript(_ header: Header) -> String? {
        get {
            self[header.rawValue]
        }
        set {
            self[header.rawValue] = newValue
        }
    }
}

extension Headers {
    var metadata: Logger.Metadata {
        var metadata: Logger.Metadata = [:]
        for (key, value) in self {
            metadata[key] = .string(value)
        }
        return metadata
    }
}
