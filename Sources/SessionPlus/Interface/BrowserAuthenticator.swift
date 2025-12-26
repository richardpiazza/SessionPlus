public protocol BrowserAuthenticator: TokenAuthenticator {
    func authenticate() async throws
}
