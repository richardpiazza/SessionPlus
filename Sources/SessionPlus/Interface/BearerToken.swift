import Foundation

public protocol BearerToken {
    var accessToken: String { get }
    var refreshToken: String? { get }
    var expirationDate: Date { get }
}

public extension BearerToken {
    var canRenew: Bool { refreshToken != nil }

    var isExpired: Bool { expirationDate <= Date() }

    var isNearingExpiration: Bool {
        guard !isExpired else {
            return true
        }

        return expirationDate.addingTimeInterval(-300) <= Date()
    }
}
