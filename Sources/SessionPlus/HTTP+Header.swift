import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension HTTP {
    /// Command HTTP Header
    struct Header: ExpressibleByStringLiteral, Equatable {
        public let rawValue: String
        
        public init(stringLiteral value: StringLiteralType) {
            rawValue = value
        }
    }
}

extension HTTP.Header: Identifiable {
    public var id: String { rawValue }
}

public extension HTTP.Header {
    /// HTTP Header date formatter; RFC1123
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"
        formatter.timeZone = TimeZone(identifier: "GMT")!
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

public extension HTTP.Header {
    /// The Accept request HTTP header advertises which content types, expressed as MIME types, the client is able to
    /// understand.
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
