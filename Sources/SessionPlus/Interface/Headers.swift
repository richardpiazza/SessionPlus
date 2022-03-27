import Foundation

public typealias Headers = [AnyHashable : Any]

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
