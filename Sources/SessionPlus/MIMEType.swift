import Foundation

public extension HTTP {
    /// MIME Types used in the API
    struct MIMEType: ExpressibleByStringLiteral, Hashable {
        public let rawValue: String
        
        public init(stringLiteral value: StringLiteralType) {
            rawValue = value
        }
    }
}

extension HTTP.MIMEType: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension HTTP.MIMEType: Identifiable {
    public var id: String { rawValue }
}

extension HTTP.MIMEType: CustomStringConvertible {
    public var description: String { rawValue }
}

public extension HTTP.MIMEType {
    /// Any kind of binary data
    static let bin: Self = "application/octet-stream"
    /// Graphics Interchange Format (GIF)
    static let gif: Self = "image/gif"
    /// HyperText Markup Language
    static let html: Self = "text/html"
    /// JPEG images
    static let jpeg: Self = "image/jpeg"
    /// JavaScript
    static let js: Self = "text/javascript"
    /// JSON Document
    static let json: Self = "application/json"
    /// JSON-LD Document
    static let jsonld: Self = "application/ld+json"
    /// Portable Network Graphics
    static let png: Self = "image/png"
    /// Adobe Portable Document Format
    static let pdf: Self = "application/pdf"
    /// Scalable Vector Graphics
    static let svg: Self = "image/svg+xml"
    /// Text
    static let txt: Self = "text/plain"
    /// XML
    static let xml: Self = "application/xml"
}
