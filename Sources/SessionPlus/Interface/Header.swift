import Foundation

/// Command HTTP Header
public struct Header: ExpressibleByStringLiteral, Hashable {
    public let rawValue: String

    public init(stringLiteral value: StringLiteralType) {
        rawValue = value
    }

    /// HTTP Header date formatter; RFC1123
    public static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"
        formatter.timeZone = TimeZone(identifier: "GMT")!
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension Header: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension Header: Identifiable {
    public var id: String { rawValue }
}

extension Header: CustomStringConvertible {
    public var description: String { rawValue }
}

public extension Header {
    /// The Accept request HTTP header advertises which content types, expressed as MIME types, the client is able to understand.
    static let accept: Self = "Accept"
    /// The HTTP Authorization request header contains the credentials to authenticate a user agent with a server,
    /// usually after the server has responded with a 401 Unauthorized status and the WWW-Authenticate header.
    static let authorization: Self = "Authorization"
    /// The Content-Length entity header is indicating the size of the entity-body, in bytes, sent to the recipient.
    static let contentLength: Self = "Content-Length"
    /// The Content-MD5 header, may be used as a message integrity check (MIC), to verify that the decoded data are the
    /// same data that were initially sent.
    static let contentMD5: Self = "Content-MD5"
    /// The Content-Type entity header is used to indicate the media type of the resource.
    static let contentType: Self = "Content-Type"
    /// The Date general HTTP header contains the date and time at which the message was originated.
    static let date: Self = "Date"
}
