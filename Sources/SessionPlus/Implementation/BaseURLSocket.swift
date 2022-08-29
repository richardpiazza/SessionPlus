import Foundation
import AsyncPlus
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
#if canImport(ObjectiveC)

open class BaseURLSocket: NSObject, Socket {
    
    private typealias ResumeHandler = (Result<Void, Error>) -> Void
    
    let baseURL: URL
    let urlRequest: URLRequest
    let keepAliveInterval: Double
    
    lazy var session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    lazy var task = session.webSocketTask(with: urlRequest)
    
    private var keepAliveTask: Task<Void, Never>?
    private var messageSequence: PassthroughAsyncThrowingSequence<WebSocket.Message> = .init()
    private var resumeHandler: ResumeHandler?
    private var pingContinuation: CheckedContinuation<Void, Error>?
    
    /// Initialize a `WebSocketService`
    ///
    /// - parameters:
    ///   - baseURL: The root **WebSocket** url path.
    ///   - authorization: Credentials needed to connect.
    ///   - keepAliveInterval: Number of seconds between ping/pong signals. (0=disabled)
    public init(baseURL: URL, authorization: Authorization? = nil, keepAliveInterval: Double = 15.0) throws {
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
        if let authorization = authorization {
            request.setValue(authorization.headerValue, forHeader: .authorization)
        }
        
        self.baseURL = url
        self.urlRequest = request
        self.keepAliveInterval = keepAliveInterval
        super.init()
    }
    
    public func start() async throws {
        try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Void, Error>) in
            resume { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        })
    }
    
    public func stop() {
        keepAliveTask?.cancel()
        pingContinuation?.resume(returning: ())
        pingContinuation = nil
        
        task.cancel(with: .normalClosure, reason: nil)
        session.invalidateAndCancel()
    }
    
    public func send(_ message: WebSocket.Message) async throws {
        let taskMessage = URLSessionWebSocketTask.Message(message)
        try await task.send(taskMessage)
    }
    
    public func receive() -> AsyncThrowingStream<WebSocket.Message, Error> {
        messageSequence = .init()
        return messageSequence.stream
    }
    
    private func resume(with handler: @escaping ResumeHandler) {
        resumeHandler = handler
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        task = session.webSocketTask(with: urlRequest)
        task.resume()
    }
    
    private func keepAlive() {
        guard keepAliveInterval > 0.0 else {
            return
        }
        
        keepAliveTask?.cancel()
        
        keepAliveTask = Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(keepAliveInterval * 1_000_000_000))
                try Task.checkCancellation()
                try await ping()
                try Task.checkCancellation()
                keepAlive()
            } catch {
                print(error)
            }
        }
    }
    
    private func ping() async throws {
        try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Void, Error>) in
            pingContinuation = continuation
            task.sendPing { [weak self] error in
                if let resumingContinuation = self?.pingContinuation {
                    if let error = error {
                        resumingContinuation.resume(throwing: error)
                    } else {
                        resumingContinuation.resume()
                    }
                    self?.pingContinuation = nil
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
        guard let error = error else {
            return
        }
        
        resumeHandler?(.failure(error))
        resumeHandler = nil
        
        stop()
    }
}

extension BaseURLSocket: URLSessionWebSocketDelegate {
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket Opened; Protocol: '\(`protocol` ?? "")'")
        resumeHandler?(.success(()))
        resumeHandler = nil
        
        task.receive { [weak self] result in
            self?.handleReceive(result)
        }
        
        keepAlive()
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
#endif
