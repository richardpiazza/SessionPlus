import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

open class BaseURLSocket: NSObject, Socket {
    
    let baseURL: URL
    let keepAliveInterval: Double
    
    lazy var session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    lazy var task = session.webSocketTask(with: baseURL)
    
    private var keepAliveTask: Task<Void, Never>?
    private var messageSequence: PassthroughAsyncThrowingSequence<WebSocket.Message> = .init()
    
    /// Initialize a `WebSocketService`
    ///
    /// - parameters:
    ///   - baseURL: The root **WebSocket** url path.
    ///   - keepAliveInterval: Number of seconds between ping/pong signals. (0=disabled)
    public init(baseURL: URL, keepAliveInterval: Double = 15.0) {
        self.baseURL = baseURL
        self.keepAliveInterval = keepAliveInterval
        super.init()
    }
    
    public func start() -> AsyncThrowingStream<WebSocket.Message, Error> {
        messageSequence = .init()
        
        task.receive { [weak self] result in
            self?.handleReceive(result)
        }
        task.resume()
        
        keepAlive()
        
        return messageSequence.stream
    }
    
    public func stop() {
        keepAliveTask?.cancel()
        task.cancel(with: .normalClosure, reason: nil)
        session.finishTasksAndInvalidate()
    }
    
    public func send(_ message: WebSocket.Message) async throws {
        let taskMessage = URLSessionWebSocketTask.Message(message)
        try await task.send(taskMessage)
    }
    
    private func keepAlive() {
        guard keepAliveInterval > 0.0 else {
            return
        }
        
        keepAliveTask?.cancel()
        
        keepAliveTask = Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(keepAliveInterval * 1_000_000_000))
                try await ping()
                keepAlive()
            } catch {
                print(error)
            }
        }
    }
    
    private func ping() async throws {
        try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Void, Error>) in
            task.sendPing { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        })
    }
    
    private func handleReceive(_ result: Result<URLSessionWebSocketTask.Message, Error>) {
        switch result {
        case .failure(let error):
            messageSequence.finish(throwing: error)
            
            stop()
        case .success(let message):
            let message = WebSocket.Message(message)
            messageSequence.yield(message)
            
            // Oddity of the `URLSessionWebSocketTask` implementation. Requires re-assignment of the
            // 'receive' completion to read the next full result.
            task.receive { [weak self] result in
                self?.handleReceive(result)
            }
        }
    }
}

extension BaseURLSocket: URLSessionDelegate {
    
}

extension BaseURLSocket: URLSessionTaskDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard error != nil else {
            return
        }
        
        stop()
    }
}

extension BaseURLSocket: URLSessionWebSocketDelegate {
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket Opened; Protocol: \(`protocol` ?? "")]")
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, closeReason: Data?) {
        let code = WebSocket.CloseCode(closeCode)
        let reason = String(data: closeReason ?? Data(), encoding: .utf8) ?? ""
        
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
