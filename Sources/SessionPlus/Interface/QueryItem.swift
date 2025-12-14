import Foundation
import Logging

public struct QueryItem: Hashable, Sendable, Codable {
    public let name: String
    public let value: String?

    public init(
        name: String,
    ) {
        self.name = name
        value = nil
    }

    public init(
        name: String,
        value: String,
    ) {
        self.name = name
        self.value = value
    }

    public init(
        name: String,
        value: Int,
    ) {
        self.name = name
        self.value = String(describing: value)
    }

    public init?(
        name: String,
        percentEncoding: String?,
    ) {
        guard let percentEncoding else {
            return nil
        }

        guard let value = percentEncoding.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }

        self.name = name
        self.value = value
    }
}

extension Collection<QueryItem> {
    var metadata: Logger.Metadata {
        var metadata: Logger.Metadata = [:]
        for element in self {
            metadata[element.name] = .string(element.value ?? "")
        }
        return metadata
    }
}
