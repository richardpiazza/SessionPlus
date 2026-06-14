import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Mutex

#if canImport(ObjectiveC)

public final class AbsoluteURLWebSocket: NSObject, WebSocket {

    let baseURL: URL
    let urlRequest: URLRequest
    let keepAliveInterval: Double

    private let startContinuation: Mutex<CheckedContinuation<Void, any Error>?> = Mutex(nil)
    private let sessionTask: Mutex<(URLSession, URLSessionWebSocketTask)?> = Mutex(nil)
    private let keepAliveTask: Mutex<Task<Void, Never>?> = Mutex(nil)
    private let messageContinuation: Mutex<AsyncThrowingStream<Socket.Message, any Error>.Continuation?> = Mutex(nil)

    private var session: URLSession? {
        sessionTask.withLock { $0?.0 }
    }

    private var socketTask: URLSessionWebSocketTask? {
        sessionTask.withLock { $0?.1 }
    }

    /// Initialize a `WebSocketService`
    ///
    /// - parameters:
    ///   - baseURL: The root **WebSocket** url path.
    ///   - authorization: Credentials needed to connect.
    ///   - keepAliveInterval: Number of seconds between ping/pong signals. (0=disabled)
    public init(
        baseURL: URL,
        authorization: Authorization? = nil,
        keepAliveInterval: Double = 15.0,
    ) throws {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw URLError(.badURL)
        }

        switch components.scheme?.lowercased() {
        case "ws", "wss":
            break
        case "http":
            components.scheme = "ws"
        case "https":
            components.scheme = "wss"
        default:
            throw URLError(.unsupportedURL)
        }

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        if let authorization {
            request.setValue(authorization.headerValue, forHeader: .authorization)
        }

        self.baseURL = url
        urlRequest = request
        self.keepAliveInterval = keepAliveInterval
        super.init()
    }

    public func start() async throws {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.webSocketTask(with: urlRequest)

        do {
            try await withCheckedThrowingContinuation { continuation in
                startContinuation.withLock {
                    $0 = continuation
                }

                task.resume()
            }
        } catch {
            stop()
            throw error
        }

        sessionTask.withLock {
            $0 = (session, task)
        }

        task.receive { [weak self] result in
            self?.handleReceive(result)
        }

        keepAlive()
    }

    public func stop() {
        keepAliveTask.withLock {
            $0?.cancel()
        }

        messageContinuation.withLock {
            $0?.finish()
            $0 = nil
        }

        socketTask?.cancel(with: .normalClosure, reason: nil)
        session?.invalidateAndCancel()

        sessionTask.withLock { $0 = nil }
    }

    public func send(_ message: Socket.Message) async throws {
        let taskMessage = URLSessionWebSocketTask.Message(message)
        try await socketTask?.send(taskMessage)
    }

    public func receive() -> AsyncThrowingStream<Socket.Message, any Error> {
        let (stream, continuation) = AsyncThrowingStream.makeStream(of: Socket.Message.self)
        continuation.onTermination = { [weak self] _ in
            self?.stop()
        }
        messageContinuation.withLock {
            $0 = continuation
        }
        return stream
    }

    private func keepAlive() {
        guard keepAliveInterval > 0.0 else {
            return
        }

        let task = Task {
            do {
                try await Task.sleep(for: .seconds(keepAliveInterval))
                try Task.checkCancellation()
                try await ping()
                try Task.checkCancellation()
                keepAlive()
            } catch {
                print(error)
            }
        }

        keepAliveTask.withLock {
            $0?.cancel()
            $0 = task
        }
    }

    private func ping() async throws {
        guard let socketTask else {
            return
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            socketTask.sendPing { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    private func handleReceive(_ result: Result<URLSessionWebSocketTask.Message, any Error>) {
        let messageContinuation = messageContinuation.withLock { $0 }

        switch result {
        case .failure(let error):
            messageContinuation?.finish(throwing: error)

            stop()
        case .success(let message):
            let message = Socket.Message(message)
            messageContinuation?.yield(message)

            // Oddity of the `URLSessionWebSocketTask` implementation. Requires re-assignment of the
            // 'receive' completion to read the next full result.
            socketTask?.receive { [weak self] result in
                self?.handleReceive(result)
            }
        }
    }
}

extension AbsoluteURLWebSocket: URLSessionDelegate {}

extension AbsoluteURLWebSocket: URLSessionTaskDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        guard let error else {
            return
        }

        startContinuation.withLock {
            $0?.resume(throwing: error)
            $0 = nil
        }
    }
}

extension AbsoluteURLWebSocket: URLSessionWebSocketDelegate {
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket Opened; Protocol: '\(`protocol` ?? "")'")

        startContinuation.withLock {
            $0?.resume(returning: ())
            $0 = nil
        }
    }

    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        let code = Socket.CloseCode(closeCode)
        let reason = String(decoding: reason ?? Data(), as: UTF8.self)

        if code == .normalClosure {
            print("""
            WebSocket Closed {
                code: \(code),
                reason: \(reason)
            }
            """)
        } else {
            print("""
            WebSocket Closed {
                code: \(code),
                reason: \(reason)
            }
            """)
        }
    }
}
#endif
