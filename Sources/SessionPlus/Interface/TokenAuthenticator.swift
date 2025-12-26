public protocol TokenAuthenticator: Authenticator {
    var token: (any BearerToken)? { get }
    
    @discardableResult func renewToken() async throws -> any BearerToken
}
