@testable import SessionPlus
import XCTest

final class QueryItemTests: XCTestCase {

    func testEncodedValue() throws {
        let nilValue = QueryItem(name: "accept", percentEncoding: nil)
        XCTAssertNil(nilValue)

        let unmodified = try XCTUnwrap(QueryItem(name: "item", percentEncoding: "fork"))
        XCTAssertEqual(unmodified.value, "fork")
        XCTAssertEqual([unmodified].metadata, ["item": .string("fork")])

        let encoded = try XCTUnwrap(QueryItem(name: "query", percentEncoding: "search term"))
        XCTAssertEqual(encoded.value, "search%20term")
        XCTAssertEqual([encoded].metadata, ["query": .string("search%20term")])
    }
}
