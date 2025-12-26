public protocol MFAAuthenticator: TokenAuthenticator {
    associatedtype Credentials
    associatedtype Challenge
    associatedtype Conclusion
    
    func authenticate(using credentials: Credentials) async throws -> Conclusion
    func issueChallenge(challenge: Challenge) async throws
    func attestChallenge(challenge: Challenge, with response: String) async throws -> Conclusion
}
