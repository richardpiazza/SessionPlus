import Foundation

/// MIME Types used in the API
public struct MIMEType: Hashable, Sendable {
    public let rawValue: String

    /// Any kind of binary data
    public static let bin: Self = "application/octet-stream"
    /// Graphics Interchange Format (GIF)
    public static let gif: Self = "image/gif"
    /// HyperText Markup Language
    public static let html: Self = "text/html"
    /// JPEG images
    public static let jpeg: Self = "image/jpeg"
    /// JavaScript
    public static let js: Self = "text/javascript"
    /// JSON Document
    public static let json: Self = "application/json"
    /// JSON-LD Document
    public static let jsonld: Self = "application/ld+json"
    /// Portable Network Graphics
    public static let png: Self = "image/png"
    /// Adobe Portable Document Format
    public static let pdf: Self = "application/pdf"
    /// Scalable Vector Graphics
    public static let svg: Self = "image/svg+xml"
    /// Text
    public static let txt: Self = "text/plain"
    /// XML
    public static let xml: Self = "application/xml"
}

extension MIMEType: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension MIMEType: CustomStringConvertible {
    public var description: String { rawValue }
}

extension MIMEType: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        rawValue = value
    }
}

extension MIMEType: Identifiable {
    public var id: String { rawValue }
}
