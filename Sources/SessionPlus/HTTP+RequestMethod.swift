import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension HTTP {
    /// Desired action to be performed for a given resource.
    ///
    /// Although they can also be nouns, these request methods are sometimes referred as HTTP verbs.
    struct RequestMethod: ExpressibleByStringLiteral, Equatable {
        public let rawValue: String
        
        public init(stringLiteral value: String) {
            rawValue = value
        }
    }
}

extension HTTP.RequestMethod: Identifiable {
    public var id: String { rawValue }
}

public extension HTTP.RequestMethod {
    /// The GET method requests a representation of the specified resource.
    ///
    /// Requests using GET should only retrieve data.
    static let get: Self = "GET"
    /// The PUT method replaces all current representations of the target resource with the request payload.
    static let put: Self = "PUT"
    /// The POST method is used to submit an entity to the specified resource, often causing a change in state or side
    /// effects on the server.
    static let post: Self = "POST"
    /// The PATCH method is used to apply partial modifications to a resource.
    static let patch: Self = "PATCH"
    /// The DELETE method deletes the specified resource.
    static let delete: Self = "DELETE"
}
