import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Logging

/// The encapsulation of information needed to perform a request against an HTTP/REST service endpoint.
public protocol Request: Sendable {
    /// Method used to address the request.
    var resource: Resource { get }
    /// The HTTP verb (action/method) associated with the request.
    var method: Method { get }
    /// Custom headers to provide in the created `URLRequest`.
    var headers: Headers? { get }
    /// Additional components that will be appended to the created `URL`.
    var queryItems: [QueryItem]? { get }
    /// Binary data that is attached to the `URLRequest`.
    var body: Data? { get }
}

public extension Request {
    @available(*, deprecated, renamed: "resource")
    var address: Address { resource }

    /// Routing path extension.
    ///
    /// This is appended to a _base URL_ instance to create an 'absolute path' to a resource.
    var path: String {
        switch resource {
        case .absolute(let url):
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.path ?? ""
        case .path(let path):
            path
        }
    }

    /// Appends (or overwrites) the **Authorization** key in the request headers.
    ///
    /// - parameters:
    ///   - token: The token which should be used for authentication.
    /// - returns: A modified `Request` that includes an authentication value.
    func authorized(_ authorization: Authorization) -> any Request {
        var headers = headers ?? [:]
        headers[.authorization] = authorization.headerValue

        return AnyRequest(
            resource: resource,
            method: method,
            headers: headers,
            queryItems: queryItems,
            body: body,
        )
    }
}

extension Request {
    var description: String {
        String(
            format: "%1$@ %2$@, Headers: %3$d, Parameters: %4$d, Bytes: %5$d",
            method.description,
            path,
            headers?.count ?? 0,
            queryItems?.count ?? 0,
            body?.count ?? 0,
        )
    }

    var debugDescription: String {
        let debugHeaders = (headers ?? [:])
            .map { "\($0.key) = \($0.value)" }
            .joined(separator: " ")

        let debugParameters = (queryItems ?? [])
            .map(\.description)
            .joined(separator: " ")

        let debugBody = String(decoding: body ?? Data(), as: UTF8.self)

        return String(
            format: "%1$@ %2$@, Headers: %3$@, Parameters: %4$@, Body: %5$@",
            method.description,
            path,
            debugHeaders,
            debugParameters,
            debugBody,
        )
    }

    var metadata: Logger.Metadata {
        [
            "resource": .stringConvertible(resource),
            "method": .stringConvertible(method),
            "bytes": .stringConvertible((body ?? Data()).count),
        ]
    }

    var verboseMetadata: Logger.Metadata {
        [
            "resource": .stringConvertible(resource),
            "method": .stringConvertible(method),
            "bytes": .stringConvertible((body ?? Data()).count),
            "body": .string(String(decoding: body ?? Data(), as: UTF8.self)),
            "headers": .dictionary((headers ?? [:]).metadata),
            "queryItems": .dictionary((queryItems ?? []).metadata),
        ]
    }
}
