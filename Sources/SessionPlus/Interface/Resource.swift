import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@available(*, deprecated, renamed: "Resource")
public typealias Address = Resource

/// The method in which a `Request` URL is described and constructed.
public enum Resource: Equatable, Sendable, Codable {
    /// The full URL including any query components.
    case absolute(URL)
    /// Routing path extension.
    ///
    /// This is appended to a _base URL_ instance to create an 'absolute path' to a resource.
    case path(String)
}

extension Resource: CustomStringConvertible {
    public var description: String {
        switch self {
        case .absolute(let url): url.absoluteString
        case .path(let path): path
        }
    }
}
