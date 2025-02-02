import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Namespace for socket related types
public enum Socket {
    /// A code that indicates why a WebSocket connection closed.
    ///
    /// These follow the close codes defined in RFC 6455
    public enum CloseCode: Int, Codable, CaseIterable {
        /// A code that indicates the connection is still open.
        case invalid = 0
        /// A code that indicates normal connection closure.
        case normalClosure = 1000
        /// A code that indicates an endpoint is going away.
        case goingAway = 1001
        /// A code that indicates an endpoint terminated the connection due to a protocol error.
        case protocolError = 1002
        /// A code that indicates an endpoint terminated the connection after receiving a type of data it can’t accept.
        case unsupportedData = 1003
        /// A reserved code that indicates an endpoint expected a status code and didn’t receive one.
        case noStatusReceived = 1005
        /// A reserved code that indicates the connection closed without a close control frame.
        case abnormalClosure = 1006
        /// A code that indicates the server terminated the connection because it received data inconsistent with the message’s type.
        case invalidFramePayloadData = 1007
        /// A code that indicates an endpoint terminated the connection because it received a message that violates its policy.
        case policyViolation = 1008
        /// A code that indicates an endpoint is terminating the connection because it received a message too big for it to process.
        case messageTooBig = 1009
        /// A code that indicates the client terminated the connection because the server didn’t negotiate a required extension.
        case mandatoryExtensionMissing = 1010
        /// A code that indicates the server terminated the connection because it encountered an unexpected condition.
        case internalServerError = 1011
        /// A reserved code that indicates the connection closed due to the failure to perform a TLS handshake.
        case tlsHandshakeFailure = 1015
    }

    public enum Message: Codable {
        case data(Data)
        case string(String)
    }
}

extension Socket.CloseCode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalid: "A code that indicates the connection is still open."
        case .normalClosure: "A code that indicates normal connection closure."
        case .goingAway: "A code that indicates an endpoint is going away."
        case .protocolError: "A code that indicates an endpoint terminated the connection due to a protocol error."
        case .unsupportedData: "A code that indicates an endpoint terminated the connection after receiving a type of data it can’t accept."
        case .noStatusReceived: "A reserved code that indicates an endpoint expected a status code and didn’t receive one."
        case .abnormalClosure: "A reserved code that indicates the connection closed without a close control frame."
        case .invalidFramePayloadData: "A code that indicates the server terminated the connection because it received data inconsistent with the message’s type."
        case .policyViolation: "A code that indicates an endpoint terminated the connection because it received a message that violates its policy."
        case .messageTooBig: "A code that indicates an endpoint is terminating the connection because it received a message too big for it to process."
        case .mandatoryExtensionMissing: "A code that indicates the client terminated the connection because the server didn’t negotiate a required extension."
        case .internalServerError: "A code that indicates the server terminated the connection because it encountered an unexpected condition."
        case .tlsHandshakeFailure: "A reserved code that indicates the connection closed due to the failure to perform a TLS handshake."
        }
    }
}

#if canImport(ObjectiveC)
public extension Socket.CloseCode {
    init(_ closeCode: URLSessionWebSocketTask.CloseCode) {
        self = Self.allCases.first(where: { $0.rawValue == closeCode.rawValue }) ?? .invalid
    }
}

public extension Socket.Message {
    init(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .data(let value):
            self = .data(value)
        case .string(let value):
            self = .string(value)
        @unknown default:
            self = .string("\(message)")
        }
    }
}

public extension URLSessionWebSocketTask.Message {
    init(_ message: Socket.Message) {
        switch message {
        case .data(let value):
            self = .data(value)
        case .string(let value):
            self = .string(value)
        }
    }
}
#endif
