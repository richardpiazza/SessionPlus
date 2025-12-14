import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import SessionPlus
import Testing

struct RequestAndResponseTests {

    private struct Name: Encodable {
        let first: String
    }

    private let url: URL

    init() throws {
        url = try #require(URL(string: "https://api.domain.com"))
    }

    @Test func initRequestWithURLRequest() throws {
        var urlRequest: URLRequest = URLRequest(url: url)
        #expect(urlRequest.url?.absoluteString == "https://api.domain.com")
        #expect(urlRequest.httpMethod == "GET")
        #expect(urlRequest.allHTTPHeaderFields == nil)
        #expect(urlRequest.httpBody == nil)

        let request = try Post(
            path: "person/name",
            headers: [
                Header.authorization.rawValue: "Example",
            ],
            queryItems: [
                QueryItem(name: "priority", value: 1),
            ],
            encoding: Name(first: "Susan"),
        )

        #expect(request.description == "POST person/name, Headers: 1, Parameters: 1, Bytes: 17")
        #expect(request.debugDescription == """
        POST person/name, Headers: Authorization = Example, Parameters: priority = 1, Body: {"first":"Susan"}
        """)

        urlRequest = try URLRequest(request: request, baseUrl: url)
        #expect(urlRequest.url?.absoluteString == "https://api.domain.com/person/name?priority=1")
        #expect(urlRequest.httpMethod == "POST")

        let headers = try #require(urlRequest.allHTTPHeaderFields)
        #expect(headers[.accept] == MIMEType.json.rawValue)
        #expect(headers[.contentType] == MIMEType.json.rawValue)
        #expect(headers[.contentLength] == "17")
        #expect(headers[.authorization] == "Example")

        let body = try #require(urlRequest.httpBody)
        let json = String(decoding: body, as: UTF8.self)
        #expect(json == #"{"first":"Susan"}"#)
    }

    @Test func urlResponseStatusCode() throws {
        var urlResponse: URLResponse = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        #expect(urlResponse.statusCode == 0)

        urlResponse = try #require(HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil))
        #expect(urlResponse.statusCode == .notFound)
    }

    @Test func urlResponseHeaders() throws {
        var urlResponse: URLResponse = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        var headers = urlResponse.headers
        #expect(headers == [:])

        urlResponse = try #require(HTTPURLResponse(url: url, statusCode: 204, httpVersion: nil, headerFields: ["X-Version": "2.3.4"]))
        headers = urlResponse.headers
        #expect(headers == ["X-Version": "2.3.4"])

        let data = try #require("{\"json\":\"data\"}".data(using: .utf8))
        let response = AnyResponse(statusCode: urlResponse.statusCode, headers: urlResponse.headers, body: data)
        #expect(response.description == "204, Headers: 1, Bytes: 15")
        #expect(response.debugDescription == """
        204, Headers: X-Version = 2.3.4, Body: {"json":"data"}
        """)
    }
}
