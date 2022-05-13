public final class PassthroughAsyncThrowingSequence<Element>: AsyncSequence {
    
    public private(set) var stream: AsyncThrowingStream<Element, Error>!
    private var continuation: AsyncThrowingStream<Element, Error>.Continuation!
    private lazy var iterator = stream.makeAsyncIterator()
    
    public init() {
        stream = AsyncThrowingStream<Element, Error> { token in
            continuation = token
        }
    }
    
    public func makeAsyncIterator() -> AsyncThrowingStream<Element, Error>.Iterator {
        iterator
    }
    
    public func yield(_ element: Element) {
        continuation.yield(element)
    }
    
    public func finish(throwing error: Error? = nil) {
        continuation.finish(throwing: error)
    }
}
