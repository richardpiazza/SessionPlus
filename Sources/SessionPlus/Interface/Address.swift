import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// The method in which a `Request` URL is described and constructed.
public enum Address: Codable {
    /// The full URL including any query components.
    case absolute(URL)
    /// Routing path extension.
    ///
    /// This is appended to a _base URL_ instance to create an 'absolute path' to a resource.
    case path(String)
}

extension Address: CustomStringConvertible {
    public var description: String {
        switch self {
        case .absolute(let url): url.absoluteString
        case .path(let path): path
        }
    }
}
