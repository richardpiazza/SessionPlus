import Foundation

/// Desired action to be performed for a given resource.
///
/// Although they can also be nouns, these request methods are sometimes referred as HTTP verbs.
public struct Method: Hashable, Sendable {
    public let rawValue: String

    /// The GET method requests a representation of the specified resource.
    ///
    /// Requests using GET should only retrieve data.
    public static let get: Self = "GET"
    /// The PUT method replaces all current representations of the target resource with the request payload.
    public static let put: Self = "PUT"
    /// The POST method is used to submit an entity to the specified resource, often causing a change in state or side
    /// effects on the server.
    public static let post: Self = "POST"
    /// The PATCH method is used to apply partial modifications to a resource.
    public static let patch: Self = "PATCH"
    /// The DELETE method deletes the specified resource.
    public static let delete: Self = "DELETE"
}

extension Method: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension Method: CustomStringConvertible {
    public var description: String { rawValue }
}

extension Method: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        rawValue = value
    }
}

extension Method: Identifiable {
    public var id: String { rawValue }
}
