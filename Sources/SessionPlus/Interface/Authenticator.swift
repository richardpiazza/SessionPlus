public protocol Authenticator {
    associatedtype Identity
    
    var identityStream: AsyncStream<Identity?> { get }
    
    func getIdentity() async throws -> Identity
    
    func deauthenticate() async throws
    
    func reset() async
}
