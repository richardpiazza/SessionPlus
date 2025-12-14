import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLQueryItem: @retroactive Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case value
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let value = try container.decodeIfPresent(String.self, forKey: .value)
        self.init(name: name, value: value)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(value, forKey: .value)
    }
}

extension URLQueryItem {
    init(_ queryItem: QueryItem) {
        self.init(name: queryItem.name, value: queryItem.value)
    }
}
