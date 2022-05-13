import Foundation

public protocol Socket {
    func start() -> AsyncThrowingStream<WebSocket.Message, Error>
    func stop()
    func send(_ message: WebSocket.Message) async throws
}
