import Foundation

/// Communications protocol providing full-duplex communication channels over a single connection.
///
/// The WebSocket protocol enables interaction between a web browser (or other client application)
/// and a web server with lower overhead than half-duplex alternatives such as HTTP polling, facilitating
/// real-time data transfer from and to the server. This is made possible by providing a standardized
/// way for the server to send content to the client without being first requested by the client, and
/// allowing messages to be passed back and forth while keeping the connection open.
public protocol WebSocket {
    /// Initialize the `WebSocket` connection
    func start() async throws
    /// Terminate the connection
    func stop()
    /// Send a `Socket.Message`
    func send(_ message: Socket.Message) async throws
    /// Receive an asynchronous stream of `Socket.Message`.
    func receive() -> AsyncThrowingStream<Socket.Message, Error>
}
