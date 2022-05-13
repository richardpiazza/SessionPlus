import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension WebSocket {
    enum Message: Codable {
        case data(Data)
        case string(String)
    }
}

public extension WebSocket.Message {
    init(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .data(let value):
            self = .data(value)
        case .string( let value):
            self = .string(value)
        @unknown default:
            self = .string("\(message)")
        }
    }
}

public extension URLSessionWebSocketTask.Message {
    init(_ message: WebSocket.Message) {
        switch message {
        case .data(let value):
            self = .data(value)
        case .string(let value):
            self = .string(value)
        }
    }
}
