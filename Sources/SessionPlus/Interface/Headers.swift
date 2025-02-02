import Foundation
import Logging

public typealias Headers = [AnyHashable: Any]

public extension Headers {
    subscript(_ header: Header) -> Any? {
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
            metadata[String(describing: key)] = .string(String(describing: value))
        }
        return metadata
    }
}
