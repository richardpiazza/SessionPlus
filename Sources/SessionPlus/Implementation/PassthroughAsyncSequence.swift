public final class PassthroughAsyncSequence<Element>: AsyncSequence {
    
    public private(set) var stream: AsyncStream<Element>!
    private var continuation: AsyncStream<Element>.Continuation!
    private lazy var iterator = stream.makeAsyncIterator()
    
    public init() {
        stream = AsyncStream<Element> { token in
            continuation = token
        }
    }
    
    public func makeAsyncIterator() -> AsyncStream<Element>.Iterator {
        iterator
    }
    
    public func yield(_ element: Element) {
        continuation.yield(element)
    }
    
    public func finish() {
        continuation.finish()
    }
}
