import Logging
@testable import SessionPlus
import Testing

struct QueryItemTests {

    @Test func encodedValue() throws {
        let nilValue = QueryItem(name: "accept", percentEncoding: nil)
        #expect(nilValue == nil)

        let unmodified = try #require(QueryItem(name: "item", percentEncoding: "fork"))
        #expect(unmodified.value == "fork")
        #expect([unmodified].metadata == ["item": .string("fork")])

        let encoded = try #require(QueryItem(name: "query", percentEncoding: "search term"))
        #expect(encoded.value == "search%20term")
        #expect([encoded].metadata == ["query": .string("search%20term")])
    }
}
