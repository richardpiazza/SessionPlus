import Foundation

public protocol Socket {
    func start() async throws
    func stop()
    func receive() -> AsyncThrowingStream<WebSocket.Message, Error>
    func send(_ message: WebSocket.Message) async throws
}
