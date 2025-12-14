import Foundation
import Logging
import Mutex

package class ProtectedState<T: Sendable>: @unchecked Sendable {

    private let state: Mutex<T>
    private let subscribers: Mutex<[UUID: AsyncStream<T>.Continuation]> = Mutex([:])

    package init(_ initialValue: T) {
        state = Mutex(initialValue)
    }

    package var value: T {
        state.withLock { $0 }
    }

    package var asyncStream: AsyncStream<T> {
        let id = UUID()
        let asyncStream = AsyncStream.makeStream(of: T.self)
        asyncStream.continuation.onTermination = { [weak self] _ in
            self?.removeSubscriber(id)
        }
        addSubscriber(id, continuation: asyncStream.continuation)

        defer {
            let level = state.withLock { $0 }
            asyncStream.continuation.yield(level)
        }

        return asyncStream.stream
    }

    package func setValue(_ value: T) {
        state.withLock { $0 = value }
        let subscribers = subscribers.withLock { $0 }
        for (_, continuation) in subscribers {
            continuation.yield(value)
        }
    }

    private func addSubscriber(_ id: UUID, continuation: AsyncStream<T>.Continuation) {
        subscribers.withLock {
            $0[id] = continuation
        }
    }

    private func removeSubscriber(_ id: UUID) {
        subscribers.withLock {
            $0[id] = nil
        }
    }
}

package extension ProtectedState where T == Logger.Level {
    convenience init(level: Logger.Level = .debug) {
        self.init(level)
    }
}
